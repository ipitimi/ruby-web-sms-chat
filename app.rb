require 'bundler'
Bundler.require

require './websocket_backend'
require './spa_backend'

byebug
class WebSmsApp < Sinatra::Base
  use WebsocketBackend
  use SpaBackend
  set :public_folder, File.dirname(__FILE__) + '/web-sms-chat-frontend'
end

if __FILE__ == $0 || __FILE__ == $1 then
  #if this file executes as main script
  WebSmsApp.run!()
end
