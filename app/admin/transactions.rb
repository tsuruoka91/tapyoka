ActiveAdmin.register Transaction do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :txid, :token_id, :amount, :address, :user_id, :to_user_id, :memo, :transaction_type
  #
  # or
  #
  # permit_params do
  #   permitted = [:txid, :token_id, :amount, :address, :user_id, :to_user_id, :memo, :transaction_type]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
