# frozen_string_literal: true

require_relative 'models'

require 'oj'
require 'roda'

class App < Roda
  COLOR = %w[red green blue].freeze

  opts[:check_dynamic_arity] = false
  opts[:check_arity] = :warn

  plugin :default_headers,
         'Content-Type' => 'text/html',
         # 'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
         'X-Frame-Options' => 'deny',
         'X-Content-Type-Options' => 'nosniff',
         'X-XSS-Protection' => '1; mode=block'

  plugin :content_security_policy do |csp|
    csp.default_src :none
    csp.style_src :self, 'https://maxcdn.bootstrapcdn.com'
    csp.form_action :self
    csp.script_src :self
    csp.connect_src :self
    csp.base_uri :none
    csp.frame_ancestors :none
  end

  plugin :json_parser
  plugin :json

  logger = if ENV['RACK_ENV'] == 'test'
             Class.new do
               def write(_) end
             end .new
           else
             $stderr
           end

  plugin :common_logger, logger

  plugin(:not_found) { 'File Not Found' }

  plugin :typecast_params, strip: :all do
    typecast_error = Roda::RodaPlugins::TypecastParams::Error

    handle_type(:color) do |v|
      raise typecast_error, "color must be one of the list: #{COLOR}" unless COLOR.any? { |color| color == v }

      v
    end
  end

  route do |r|
    r.on 'users' do
      r.on Integer do |user_id|
        @user = User[user_id]

        next { error: 'User not found' } unless @user

        r.on 'cards' do
          r.post 'buy' do
            @user.add_debit_card(color: typecast_params.color!('color'), count: typecast_params.pos_int!('count'))

            { success: 'Cards bought' }
          end

          r.post 'use' do
            if @user.use_card(typecast_params.color!('color'))
              { success: 'Card used' }
            else
              { unsuccess: 'The cards are over.' }
            end
          end
        end
      end
    end
  end
end