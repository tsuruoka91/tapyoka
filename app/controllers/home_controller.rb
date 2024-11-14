class HomeController < ApplicationController
  def index
    @users = User.order('id')
    @users = @users.where(role: :user) unless view_context.admin?
    @transactions = Transaction.order('id DESC').limit(5)
    @transactions = @transactions.where.not(disabled: true) unless view_context.admin?
  end

  def change_admin
    if session[:admin]
      session[:admin] = nil
    else
      session[:admin] = 1
    end
    redirect_to home_url
  end
end
