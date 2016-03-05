require 'bundler'
require 'yaml'
Bundler.require


Bandwidth::Client.global_options = {:user_id => ENV['CATAPULT_USER_ID'], :api_token => ENV['CATAPULT_API_TOKEN'], :api_secret => ENV['CATAPULT_API_SECRET']}


class WebSmsApp < Sinatra::Base
  use Rack::PostBodyContentTypeParser
  set :public_folder, File.dirname(__FILE__) + '/public'

  get '/' do
    redirect '/index.html'
  end

end

if __FILE__ == $0 || __FILE__ == $1
  #if this file executes as main script
  WebSmsApp.run!()
end
