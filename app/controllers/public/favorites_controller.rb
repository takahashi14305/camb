class Public::FavoritesController < ApplicationController
  before_action :ensure_normal_user, only: %i[create destroy]

  def create
    @post_image = PostImage.find(params[:post_image_id])
    favorite = current_user.favorites.new(post_image_id: @post_image.id)
    favorite.save
    #redirect_to post_image_path(post_image)
  end

  def destroy
    @post_image = PostImage.find(params[:post_image_id])
    favorite = current_user.favorites.find_by(post_image_id: @post_image.id)
    favorite.destroy
    #redirect_to post_image_path(post_image)
  end

  def ensure_normal_user
    user = current_user
    if user.email == 'guest@exp.com'
      flash[:notice] = "ゲストユーザーはイイねできません。"
      redirect_to user_path(user.id)
    end
  end

end
