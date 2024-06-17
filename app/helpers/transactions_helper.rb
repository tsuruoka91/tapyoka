module TransactionsHelper
  def recipient_users(user_id)
    users = User.where.not(id: user_id)
    users = users.where(role: :user) unless admin?
    users
  end
end
