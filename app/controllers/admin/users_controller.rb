class Admin::UsersController < ApplicationController

  def index
    @user = User.page(params[:page]).per(10)
  end
end
