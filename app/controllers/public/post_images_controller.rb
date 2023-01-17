class Public::PostImagesController < ApplicationController
  before_action :post_images_search
  def new
    @post_image = PostImage.new
    @current_user = current_user
  end

  def create
    @post_image = PostImage.new(post_image_params)
    @post_image.user_id = current_user.id
    if @post_image.save
      redirect_to post_images_path
    else
      render :new
    end
  end

  def index
    @post_images = PostImage.page(params[:page]).per(8).order(created_at: :desc)
    @current_user = current_user
    @search_u = User.ransack(params[:q])
    #@search_users = @search_u.result
    @search_p = PostImage.ransack(params[:q])
    #@search_post_images = @search_p.result
  end

  def show
    @post_image = PostImage.find(params[:id])
    @post_comment = PostComment.new
    @current_user = current_user
    @user = @post_image.user
  end

  def destroy
    @post_image = PostImage.find(params[:id])
    @post_image.destroy
    @user = current_user
    redirect_to user_path(@user.id)
  end

  def edit
    @post_image = PostImage.find(params[:id])
  end

  def update
    post_image = PostImage.find(params[:id])
    post_image.update(post_image_params)
    redirect_to post_image_path(post_image.id)
  end

  def post_images_search
    @search_p = PostImage.ransack(params[:q])
    @search_post_images = @search_p.result
  end

  def favorite
    @current_user = current_user
    @post_images = PostImage.favorites.order("favorites_count DESC").select("post_images.*")
  end

  private

  def post_image_params
    params.require(:post_image).permit(:title, :image, :body)
  end
end
