class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :to_user, class_name: "User", foreign_key: "to_user_id", optional: true

  enum transaction_type: { transfer: 1, burn: 2 }
end
