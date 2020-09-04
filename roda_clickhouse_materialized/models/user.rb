# frozen_string_literal: true

require_relative '../clickhouse'

class User < Sequel::Model
  MAX_CREDIT = 0

  def use_card(color)
    debit = ClickHouse.connection.select_value(<<-SQL
      SELECT sum(count) FROM materialized_debit WHERE ((user_id = #{id}) AND (color = '#{color}')) GROUP BY (user_id, color)
    SQL
    ) || 0

    credit = ClickHouse.connection.select_value(<<-SQL
      SELECT sum(count) FROM materialized_credit WHERE ((user_id = #{id}) AND (color = '#{color}')) GROUP BY (user_id, color)
    SQL
    ) || 0

    if debit - credit > MAX_CREDIT
      ClickHouse.connection.insert('credit', columns: %i[user_id color], values: [[id, color]])
    else
      false
    end
  end
end

# Table: users
# Columns:
#  id   | integer | PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY
#  name | text    | NOT NULL
# Indexes:
#  users_pkey | PRIMARY KEY btree (id)
# Referenced By:
#  debit_cards  | debit_cards_user_id_fkey  | (user_id) REFERENCES users(id)
#  credit_cards | credit_cards_user_id_fkey | (user_id) REFERENCES users(id)