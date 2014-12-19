require 'rubygems'
require 'sinatra'
require 'pry'

#set :sessions, true
use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => '1234acb'

helpers do

  def preparedeck
    suits = ['Heart', 'Diamond', 'Spade', 'Club']
    cards = ['2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace']
    deck = suits.product(cards)
    deck.shuffle!
  end

  def calculate_total(cards)
    sum = 0
    cards.each do |card|
      sum += card2value(card[1])
    end
    cards.select{|e| e[0] == "Ace"}.count.times do
      sum -= 10 if sum > 21
    end
    sum
  end

  def card2value(card)
    card_values = {'2'=>2, '3'=>3, '4'=>4, '5'=>5, '6'=>6, '7'=>7, '8'=>8, '9'=>9, '10'=>10, 'Jack'=>10, 'Queen'=>10, 'King'=>10, 'Ace'=>11}
    return card_values.fetch(card)
  end

end

get '/' do

  session[:deck] = preparedeck #create deck and shuffle

  if session[:player_name] = "" #if player name is not set, redirect to set_name
    erb :set_name
  else
    erb :place_bet
  end
end


post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/place_bet'
end


get '/place_bet' do
  erb :place_bet
end

post '/place_bet' do
  session[:player_cash] = 500
  session[:amount] = params[:amount]

end


get '/game' do
  #session[:deck] = [['2','D'], ['3','H']]


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


#set user name
