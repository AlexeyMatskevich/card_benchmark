# frozen_string_literal: true

require_relative 'models'

require 'sinatra/base'
require 'sinatra/json'
require 'logger'

class App < Sinatra::Base
  set :server, :puma
  set :json_encoder, :to_json
  set :logger, Logger.new(STDOUT)

  post '/users/:id/cards/buy' do
    @user = User[params['id']]

    next json({ error: 'User not found' }) unless @user

    @user.add_debit_card(color: json_body['color'], count: json_body['count'])
    json({ success: 'Cards bought' })
  end

  post '/users/:id/cards/use' do
    @user = User[params['id']]

    next json({ error: 'User not found' }) unless @user

    if @user.use_card(json_body['color'])
      json({ success: 'Card used' })
    else
      json({ unsuccess: 'The cards are over.' })
    end
  end

  private

  def json_body
    @json ||= JSON.parse(request.body.read)
  end
end
