class AddAmountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :amount, :integer
  end
end
