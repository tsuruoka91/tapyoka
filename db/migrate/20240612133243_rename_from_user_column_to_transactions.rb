class RenameFromUserColumnToTransactions < ActiveRecord::Migration[7.0]
  def change
    rename_column :transactions, :from_user_id, :user_id
  end
end
