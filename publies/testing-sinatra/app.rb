require 'sinatra/base'
require 'json'
require 'tilt/erb'

class App < Sinatra::Base

  set :views, File.dirname(__FILE__)

  # Get status of the API
  get '/status' do
    content_type :json
    [200, {:status => 'OK'}.to_json]
  end

  # Get main html page using erb
  get '/' do
    @content = 'OK'
    erb :'index.html'
  end

end