require 'rubygems'
require 'sinatra'
require 'pry'

#set :sessions, true
use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => '1234acb'

helpers do

  def get_new_card(deck, deck2)
    rand_num = rand(1..2)
    if rand_num == 1
      return deck.pop
    else
      return deck2.pop
    end
  end

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
    cards.select{|e| e[1] == "Ace"}.count.times do
      sum -= 10 if sum > 21
    end
    sum
  end

  def card2value(card)
    card_values = {'2'=>2, '3'=>3, '4'=>4, '5'=>5, '6'=>6, '7'=>7, '8'=>8, '9'=>9, '10'=>10, 'Jack'=>10, 'Queen'=>10, 'King'=>10, 'Ace'=>11}
    return card_values.fetch(card)
  end

  def card2image(card)
    suit = card[0].downcase
    value = card[1].downcase

    "<img src='/images/cards/#{suit}s_#{value}.jpg' class='card_image' />"
    #return "<img src='/images/cards/" + suit + "s_" + value + ".jpg' />"
  end

end


before do
  @show_hit_stay_buttons = true
  @show_first_dealer_card = false
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
  if params[:player_name].empty?
    @error = "Name required!"
    halt erb(:set_name)
  end

  session[:player_name] = params[:player_name]
  session[:player_cash] = 500

  redirect '/place_bet'
end


get '/place_bet' do
  if session[:player_cash] <= 0
    @error = "Go jump off a bridge and start over!"
    redirect '/'
  end

  erb :place_bet
end

post '/place_bet' do


  if params[:amount].to_i < 0 || params[:amount] == ""
    @error = "Please enter an amount above 0!"
    halt erb(:place_bet)
  elsif params[:amount].to_i > session[:player_cash]
    @error = "You better mortgage your house first!"
    halt erb(:place_bet)
  end


  session[:amount] = params[:amount].to_i
  session[:deck] = preparedeck
  session[:player_cards] =[]
  session[:dealer_cards] = []

  redirect '/game'

end


get '/game' do

  if session[:player_cards].empty?
    2.times do
      session[:player_cards] << session[:deck].pop
      session[:dealer_cards] << session[:deck].pop
    end
  end

  if calculate_total(session[:player_cards]) == 21
    @success = "BlackJack! You Won!"
    session[:player_cash] = session[:player_cash] +  session[:amount]*2
    @show_hit_stay_buttons = false
  end

  session[:player_sum] = calculate_total(session[:player_cards])
  session[:dealer_sum] = calculate_total(session[:dealer_cards])

  #binding.pry

  erb :game
end

post '/game/player/hit' do

  session[:player_cards] << session[:deck].pop

  if calculate_total(session[:player_cards]) == 21
    @success = "BlackJack! You Won!"
    session[:player_cash] = session[:player_cash] +  session[:amount]*2
  elsif calculate_total(session[:player_cards]) > 21
    @error = "Sorry, you went bust!"
    session[:player_cash] = session[:player_cash] - session[:amount]
    @show_hit_stay_buttons = false
  end


  erb :game
end

post '/game/player/stay' do

  @success = "You have chosen to stay!"

  redirect '/game/dealer'

end

get '/game/dealer' do
  @show_hit_stay_buttons = false
  @show_first_dealer_card = true



  if calculate_total(session[:dealer_cards]) == 21
    @error = "Sorry, looks like dealer hit BlackJack..."
    session[:player_cash] = session[:player_cash] - session[:amount]
  elsif calculate_total(session[:dealer_cards]) > 21
    @success = "Congrats, dealer just went bust, you win!"
    session[:player_cash] = session[:player_cash] + session[:amount]
  elsif calculate_total(session[:dealer_cards]) >= 17
    #dealer stays
    redirect '/game/check_win'
  else
    #dealer hit
    @show_dealer_hit_button = true
  end

  erb :game

end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect 'game/dealer'
end

get '/game/check_win' do
  @show_hit_stay_buttons = false

  player_sum = calculate_total(session[:player_cards])
  dealer_sum = calculate_total(session[:dealer_cards])

  #binding.pry

  if player_sum > dealer_sum
    @success = "Congrats " + session[:player_name].to_s + ", you win, top job!"
    session[:player_cash] = session[:player_cash] + session[:amount]
  elsif player_sum <= dealer_sum
    @error = "Sorry " + session[:player_name].to_s + ", you lose!"
    session[:player_cash] = session[:player_cash] - session[:amount]
  else
    @error = "Tie, no one wins."
  end

  #binding.pry

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
