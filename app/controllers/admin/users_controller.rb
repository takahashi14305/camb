class Admin::UsersController < ApplicationController
  #before_action :ensure_normal_user
  before_action :user_search

  def index
    @user = User.page(params[:page]).per(20)
  end

  def show
    @user = User.find(params[:id])
    @post_images = @user.post_images.page(params[:page]).per(16).order(created_at: :desc)
    @current_user = current_user
    @search_u = User.ransack(params[:q])
    @search_users = @search_u.result
    @search_p = PostImage.ransack(params[:p])
    @search_post_images = @search_p.result
  end

  def edit
    @user = User.find(params[:id])
    @current_user = current_user
  end

  def update
    @user = User.find(params[:id])
    @user.update(user_params)
    redirect_to admin_user_path(@user.id)
  end

  def withdrawal
    @user = User.find(params[:id])
    # is_deletedカラムをtrueに変更することにより削除フラグを立てる
    @user.update(is_deleted: !@user.is_deleted)
    flash[:notice] = "ステータス変更を実行いたしました"
    redirect_to admin_users_path
  end

  def favorites
    @user = User.find_by(id: params[:id])
    @current_user = current_user
    @favorites = Favorite.where(user_id: @current_user.id)
  end

 # def ensure_normal_user
   # @user = User.find(params[:id])
  #  if user.email == 'guest@exp.com'
  #    flash[:notice] = "ゲストユーザーは更新･削除できません。"
  #    redirect_to root_path
  #  end
 # end

  def user_search
    @search_u = User.ransack(params[:q])
    @search_users = @search_u.result
  end

  private

  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end
end
