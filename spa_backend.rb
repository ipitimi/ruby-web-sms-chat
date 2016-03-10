require "faye/websocket"
require "json"
require "securerandom"


class SpaBackend
  def initialize(app)
    @app = app
  end

  EXCLUDE_PATHES = ["/index.html", "/config.js", "/app/", "/styles/", "/node_modules/", "/vendor.js", "/__sinatra__/", ".map"]

  def call(env)
    method = env["REQUEST_METHOD"]
    path = env["REQUEST_PATH"]
    if method == "GET" && (EXCLUDE_PATHES.select {|p| path.include?(p)}).length == 0 && path != "/"
      return [301, {"Location" => "/index.html"}, [""]]
    end
    @app.call(env)
  end
end
