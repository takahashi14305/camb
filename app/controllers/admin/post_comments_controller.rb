class Admin::PostCommentsController < ApplicationController

  def destroy
    @post_image = PostImage.find(params[:post_image_id])
    @post_comment = PostComment.new
    PostComment.find(params[:id]).destroy
    #redirect_to admin_post_image_path(params[:post_image_id])
  end

  private

  def post_comment_params
    params.require(:post_comment).permit(:comment)
  end
end
