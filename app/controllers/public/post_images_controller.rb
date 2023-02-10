class Public::PostImagesController < ApplicationController
  before_action :ensure_normal_user, only: %i[new create destroy update edit]
  before_action :post_images_search
  def new
    @post_image = PostImage.new
    @current_user = current_user
  end

  def create
    @post_image = PostImage.new(post_image_params)
    @post_image.user_id = current_user.id
    if @post_image.save
      flash[:notice] = "投稿に成功しました"
      redirect_to post_images_path
    else
      render :new
    end
  end

  def index
    @post_images = PostImage.page(params[:page]).per(18).order(created_at: :desc)
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
    @currentRoomUser = RoomUser.where(user_id: @current_user)
    @receiveUser = RoomUser.where(user_id: @user.id)
    unless @user.id == @current_user  #current_userと@userが一致していなければ
      @currentRoomUser.each do |cu|    #current_userが参加していルームを取り出す
        @receiveUser.each do |u|    #@userが参加しているルームを取り出す
          if cu.room_id == u.room_id    #current_userと@userのルームが同じか判断(既にルームが作られているか)
            @have_room = true    #falseの時(同じじゃない時)の条件を記述するために変数に代入
            @room = cu.room   #ルームが共通しているcurrent_userと@userに対して変数を指定
          end
        end
      end
      unless @have_room    #ルームが同じじゃなければ
        #新しいインスタンスを生成
        @room = Room.new
        @RoomUser = RoomUser.new
        #//新しいインスタンスを生成
      end
    end
  end

  def destroy
    @post_image = PostImage.find(params[:id])
    @post_image.destroy
    flash[:notice] = "投稿を削除しました"
    @user = current_user
    redirect_to user_path(@user.id)
  end

  def edit
    @post_image = PostImage.find(params[:id])
  end

  def update
    post_image = PostImage.find(params[:id])
    if post_image.update(post_image_params)
      flash[:notice] = "編集が完了しました"
      redirect_to post_image_path(post_image.id)
    else
      flash[:notice] = "編集に失敗しました。"
      redirect_to post_image_path(post_image.id)
    end
  end

  def post_images_search
    @search_p = PostImage.ransack(params[:q])
    @search_post_images = @search_p.result.page(params[:page]).per(18).order(created_at: :desc)
    @search_u = User.ransack(params[:q])
  end

  def favorite
    @current_user = current_user
    #@post_images = PostImage.favorites.order("favorites_count DESC").select("post_images.*")
    post_image = PostImage.find(Favorite.group(:post_image_id).order('count(post_image_id) DESC').pluck(:post_image_id))
    @post_images = Kaminari.paginate_array(post_image).page(params[:page]).per(18)
    @search_p = PostImage.ransack(params[:q])
    @search_u = User.ransack(params[:q])
  end

  def ensure_normal_user
    user = current_user
    if user.email == 'guest@exp.com'
      flash[:notice] = "ゲストユーザーは閲覧のみ可能です。"
      redirect_to user_path(user.id)
    end
  end

  private

  def post_image_params
    params.require(:post_image).permit(:title, :body, image: [])
  end
end
