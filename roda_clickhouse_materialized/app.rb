# frozen_string_literal: true

require_relative 'models'

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
        r.on 'cards' do
          r.post 'buy' do
            data = [user_id, typecast_params.color!("color"), typecast_params.pos_int!("count")]
            ClickHouse.connection.insert('debit', columns: %i[user_id color count], values: [data])

            { success: 'Cards bought' }
          end

          r.post 'use' do
            color = typecast_params.color!("color")
            debit = ClickHouse.connection.select_value(<<-SQL
              SELECT sum(count) FROM materialized_debit WHERE ((user_id = #{user_id}) AND (color = '#{color}')) GROUP BY (user_id, color)
            SQL
            ) || 0

            credit = ClickHouse.connection.select_value(<<-SQL
              SELECT sum(count) FROM materialized_credit WHERE ((user_id = #{user_id}) AND (color = '#{color}')) GROUP BY (user_id, color)
            SQL
            ) || 0

            result = if debit - credit > 0
              ClickHouse.connection.insert('credit', columns: %i[user_id color], values: [[user_id, color]])
            else
              false
            end

            if result
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
