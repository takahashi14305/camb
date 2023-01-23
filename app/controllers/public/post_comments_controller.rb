class Public::PostCommentsController < ApplicationController
  before_action :ensure_normal_user, only: %i[create destroy]
  def create
    @post_image = PostImage.find(params[:post_image_id])
    @post_comment = PostComment.new
    comment = current_user.post_comments.new(post_comment_params)
    comment.post_image_id = @post_image.id
    comment.save
    #redirect_to post_image_path(post_image)
  end

  def destroy
    @post_image = PostImage.find(params[:post_image_id])
    @post_comment = PostComment.new
    PostComment.find(params[:id]).destroy
    #redirect_to post_image_path(params[:post_image_id])
  end

  def ensure_normal_user
    user = current_user
    if user.email == 'guest@exp.com'
      flash[:notice] = "ゲストユーザーはコメントできません。"
      redirect_to post_images_path
    end
  end

  private

  def post_comment_params
    params.require(:post_comment).permit(:comment)
  end

end
