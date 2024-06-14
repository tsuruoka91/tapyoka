class HomeController < ApplicationController
  def index
    @userinfo = TapyrusApi.get_userinfo
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
