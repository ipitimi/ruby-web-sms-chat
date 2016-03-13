require "bundler"
Bundler.require

require "./websocket_backend"
require "./spa_backend"


class WebSmsApp < Sinatra::Base
  use WebsocketBackend
  use SpaBackend
  set :public_dir, File.join(File.dirname(__FILE__), "web-sms-chat-frontend")

  get "/" do
    redirect "/index.html"
  end

  # return gzipped file
  get "/vendor.js" do
    vendor = File.join(File.dirname(__FILE__), "web-sms-chat-frontend", "vendor.js.gz")
    headers["Content-Encoding"] = "gzip"
    send_file vendor, {type: "application/javascript"}
  end

  # upload a file before send MMS
  post "/upload" do
    puts "Uploading file"
    file_name = SecureRandom.hex()
    file = params["file"][:tempfile]
    type = params["file"][:type]
    auth = JSON.parse(env["HTTP_AUTHORIZATION"] || "{}", {create_additions: false})
    client = Bandwidth::Client.new(auth["userId"], auth["apiToken"], auth["apiSecret"])
    Bandwidth::Media.upload client, file_name, file, type
    content_type "application/json"
    "{\"fileName\": \"#{file_name}\"}"
  end

  # callback from catapult
  post "/:user_id/callback" do
    user_id = params["user_id"]
    puts "Handling Catapult callback for user Id #{user_id}"
    json = env["rack.input"].read
    body = JSON.parse(json, {create_additions: false})
    puts "Data from Catapult for #{user_id}: #{json}"
    ((env["websockets"] || []).select {|c| c.user_id == user_id}).each do |c|
      puts "Sending Catapult data to websocket client"
      c.emit_event("message", body)
    end
  end
end

if __FILE__ == $0 || __FILE__ == $1 then
  #if this file executes as main script
  WebSmsApp.run!()
end
