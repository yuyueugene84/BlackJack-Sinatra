require 'rubygems'
require 'sinatra'
require 'pry'

#set :sessions, true
use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => '1234acb'

helpers do
  def calculate_total(card)

  end
end

get '/' do
  erb :set_name
end

post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  session[:deck] = [['2','D'], ['3','H']]
  session[:player_cards] = []

  2.times do
  session[:player_cards] << session[:deck].pop
  end

  erb :game
end

get '/nested' do
  erb :"/user/post"
end

# get '/test' do
#   #{}"from test action " + params[:some].to_s
#   @error = "this is an error!"
#   @my_var = "Eugene"
#   erb :test
# end