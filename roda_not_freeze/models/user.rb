# frozen_string_literal: true

class User < Sequel::Model
  one_to_many :credit_cards
  one_to_many :debit_cards

  MAX_CREDIT = 0

  def use_card(color)
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
