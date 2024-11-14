class AddDisabledToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :disabled, :boolean, :default => false
  end
end
