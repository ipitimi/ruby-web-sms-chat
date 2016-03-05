require "faye/websocket"
require "json"
require "securerandom"


class SpaBackend
  def initialize(app)
    @app = app
  end

  EXCLUDE_PATHES = ["/index.html", "/config.js", "/app/", "/styles/", "/node_modules/", "/vendor.js", "/__sinatra__/"]

  def call(env)
    method = env["REQUEST_METHOD"]
    path = env["REQUEST_PATH"]
    case method
      when "POST"
        if path =~ /\/(?<user_id>[\w\-\_]+)\/callback$/i
          user_id = Regexp.last_match[:user_id]
          puts "Handling Catapult callback for user Id #{user_id}"
          json = env["rack.input"].read
          body = JSON.parse(json, {create_additions: false})
          puts "Data from Catapult for #{user_id}: #{json}"
          ((env["websockets"] || []).select {|c| c.user_id == user_id}).each do |c|
            puts "Sending Catapult data to websocket client"
            c.emit_event("message", body)
          end
          return [200, {}, [""]]
        end
        if path == "/upload"
          puts "Uploading file"
          file_name = "#{SecureRandom.hex()}#{params["file"][:filename]}"
          file = params["file"][:tempfile]
          type = params["file"][:type]
          auth = JSON.parse(env["HTTP_AUTHORIZATION"] || "{}", {create_additions: false})
          client = Bandwidth::Client.new(auth["userId"], auth["apiToken"], auth["apiSecret"])
          Bandwidth::Media.upload client, file_name, file, type
          return [200, {"Content-Type" => "application/json"}, ["{\"fileName\": #{file_name}}"]]
        end
      when "GET"
        if (EXCLUDE_PATHES.select {|p| path.include?(p)}).length == 0 && path != "/"
          return [301, {"Location" => "/index.html"}, [""]]
        end
    end
    @app.call(env)
  end
end
