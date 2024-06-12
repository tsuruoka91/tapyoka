json.extract! transaction, :id, :txid, :token_id, :amount, :address, :from_user_id, :to_user_id, :memo, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
