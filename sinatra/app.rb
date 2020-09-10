# frozen_string_literal: true

require_relative 'models'

require 'sinatra/base'
require 'sinatra/json'

class App < Sinatra::Base
  set :server, :puma
  set :json_encoder, :to_json

  post '/users/:id/cards/buy' do
    DB[:debit_cards].insert(user_id: params['id'], count: json_body['count'], color: json_body['color'])

    json({ success: 'Cards bought' })
  end

  post '/users/:id/cards/use' do
    result, color = nil, json_body['color']
    debit = DB[:debit_cards].where(user_id: params['id'], color: color).sum(:count) || 0

    DB.transaction(isolation: :repeatable) do
      credit = DB[:credit_cards].where(user_id: params['id'], color: color).count || 0

      result = if debit - credit > 0
        DB[:credit_cards].insert(user_id: params['id'], color: color)
      else
        false
      end
    end

    if result
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
