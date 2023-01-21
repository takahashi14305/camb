class Public::RelationshipsController < ApplicationController
  before_action :ensure_normal_user, only: %i[create destroy followings followers]

  def create
    current_user.follow(params[:user_id])
    redirect_to request.referer
  end

  def destroy
    current_user.unfollow(params[:user_id])
    redirect_to request.referer
  end

  def followings
    @user = User.find(params[:user_id])
    @users = @user.followings.page(params[:page]).per(10)
  end

  def followers
    @user = User.find(params[:user_id])
    @users = @user.followers.page(params[:page]).per(10)
  end

  def ensure_normal_user
    user = current_user
    if user.email == 'guest@exp.com'
      flash[:notice] = "ゲストユーザーはフォローできません。"
      redirect_to root_path
    end
  end
end
