class CreateTransfers < ActiveRecord::Migration[7.0]
  def change
    create_table :transfers do |t|
      t.string :txid
      t.string :token_id
      t.integer :amount
      t.string :address
      t.integer :from_user_id
      t.integer :to_user_id
      t.text :memo

      t.timestamps
    end
  end
end
