# frozen_string_literal: true

class User < Sequel::Model
  one_to_many :credit_cards
  one_to_many :debit_cards

  MAX_CREDIT = 0

  def use_card(color)
    debit = debit_cards_dataset.where(color: color).sum(:count) || 0
    credit = credit_cards_dataset.where(color: color).count || 0

    if debit - credit > MAX_CREDIT
      add_credit_card(color: color)
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