class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :to_user, class_name: "User", optional: true

  enum transaction_type: { transfer: 1, burn: 2, gift: 3}

  validates :user_id, presence: true
  validates :to_user_id, presence: true, if: :transfer?
  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
