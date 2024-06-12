class ChangeTransfersToTransactions < ActiveRecord::Migration[7.0]
  def change
    rename_table :transfers, :transactions
  end
end
