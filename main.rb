require 'rubygems'
require 'sinatra'
require 'pry'

#set :sessions, true
use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => '1234acb'

BLACKJACK_AMOUNT = 21
DEALER_HIT_BACK_MIN = 17
PLAYER_INITIAL_CASH = 500

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
      sum -= 10 if sum > BLACKJACK_AMOUNT
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

  def blackjack!(msg)
    @success = "<strong>Congrats to #{session[:player_name]}! #{msg} </strong>"
    session[:player_cash] = session[:player_cash] + session[:amount]*2
    @show_hit_stay_buttons = false
    @play_again = true
  end

  def winner!(msg)
    @success = "<strong>#{session[:player_name]} wins! #{msg}</strong>"
    session[:player_cash] = session[:player_cash] + session[:amount]
    @show_hit_stay_buttons = false
    @play_again = true
  end

  def loser!(msg)
    @error = "Sorry, looks like #{session[:player_name]} loses. #{msg}"
    session[:player_cash] = session[:player_cash] - session[:amount]
    @show_hit_stay_buttons = false
    @play_again = true
  end

  def tie!(msg)
    @success = "Looks like it's a tie! #{msg}"
    @play_again = true
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
  session[:player_cash] = PLAYER_INITIAL_CASH

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
  session[:turn] = "player"

  redirect '/game'

end


get '/game' do
  @play_again = false

  if session[:player_cards].empty?
    2.times do
      session[:player_cards] << session[:deck].pop
      session[:dealer_cards] << session[:deck].pop
    end
  end

  if calculate_total(session[:player_cards]) == BLACKJACK_AMOUNT
    # @success = "BlackJack! You Won!"
    # session[:player_cash] = session[:player_cash] +  session[:amount]*2
    # @show_hit_stay_buttons = false

    blackjack!("BlackJack! #{session[:player_name]} Won!")
  end

  session[:player_sum] = calculate_total(session[:player_cards])
  session[:dealer_sum] = calculate_total(session[:dealer_cards])

  erb :game
end

post '/game/player/hit' do
  session[:turn] = "neo"

  session[:player_cards] << session[:deck].pop

  if calculate_total(session[:player_cards]) == BLACKJACK_AMOUNT
    blackjack!("BlackJack! #{session[:player_name]} Won!")
  elsif calculate_total(session[:player_cards]) > BLACKJACK_AMOUNT
    loser!("Sorry, #{session[:player_name]} just went bust!")
  end


  erb :game, layout: false
end

post '/game/player/stay' do
  @success = "You have chosen to stay!"

  redirect '/game/dealer'
end

get '/game/dealer' do
  @show_hit_stay_buttons = false
  @show_first_dealer_card = true
  session[:turn] = "matrix"

  if calculate_total(session[:dealer_cards]) == BLACKJACK_AMOUNT
    loser!("Sorry, looks like dealer hit BlackJack...")
  elsif calculate_total(session[:dealer_cards]) > BLACKJACK_AMOUNT
    winner!("Congrats, dealer just went bust, you win!")
  elsif calculate_total(session[:dealer_cards]) >= DEALER_HIT_BACK_MIN
    #dealer stays
    redirect '/game/check_win'
  else
    #dealer hit
    @show_dealer_hit_button = true
  end

  erb :game, layout: false

end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect 'game/dealer'
end

#if no one hit blackjack, compare two player's amount and determine the winner
get '/game/check_win' do
  @show_hit_stay_buttons = false

  player_sum = calculate_total(session[:player_cards])
  dealer_sum = calculate_total(session[:dealer_cards])

  if player_sum > dealer_sum
    winner!("Congrats #{session[:player_name]}, you win, top job!")
  elsif player_sum < dealer_sum
    loser!("Sorry #{session[:player_name]}, you lose!")
  else
    tie!("No one wins.")
  end

  erb :game, layout: false
end

#list amount of money made by player
get '/game_over' do

  @profit = session[:player_cash] - PLAYER_INITIAL_CASH

  if @profit > 0
    @msg = "Great job! You made #{@profit}!"
  elsif @profit == 0
    @msg = "No hard feelings!"
  else
    @msg = "You may want to consider mortgage your house."
  end

  erb :game_over

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
