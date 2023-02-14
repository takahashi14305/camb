class Public::HomesController < ApplicationController
  def top
  end

  def about
    @search_p = PostImage.ransack(params[:q])
    @search_u = User.ransack(params[:q])
  end
end
