require "bundler"
Bundler.require

require "./websocket_backend"
require "./spa_backend"


class WebSmsApp < Sinatra::Base
  use WebsocketBackend
  use SpaBackend
  set :public, File.join(File.dirname(__FILE__), "web-sms-chat-frontend")

  get "/" do
    redirect "/index.html"
  end

  get "/vendor.js" do
    vendor = File.join(File.dirname(__FILE__), "web-sms-chat-frontend", "vendor.js.gz")
    headers["Content-Encoding"] = "gzip"
    send_file vendor, {type: "application/javascript"}
  end
end

if __FILE__ == $0 || __FILE__ == $1 then
  #if this file executes as main script
  WebSmsApp.run!()
end
