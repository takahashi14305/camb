class Public::UsersController < ApplicationController
  before_action :ensure_normal_user, only: %i[withdrawal update edit]
  before_action :user_search
  def show
    @user = User.find(params[:id])
    @post_images = @user.post_images.page(params[:page]).per(8).order(created_at: :desc)
    @current_user = current_user
    @search_u = User.ransack(params[:q])
    @search_users = @search_u.result
    @search_p = PostImage.ransack(params[:p])
    @search_post_images = @search_p.result
    @currentRoomUser = RoomUser.where(user_id: current_user.id)  #current_userが既にルームに参加しているか判断
    @receiveUser = RoomUser.where(user_id: @user.id)  #他の@userがルームに参加しているか判断

    unless @user.id == current_user.id  #current_userと@userが一致していなければ
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

  def edit
    @user = User.find(params[:id])
    @current_user = current_user
  end

  def update
    @user = User.find(params[:id])
    @user.update(user_params)
    redirect_to user_path(@user.id)
  end

  def withdrawal
    @user = User.find(params[:id])
    # is_deletedカラムをtrueに変更することにより削除フラグを立てる
    @user.update(is_deleted: true)
    reset_session
    flash[:notice] = "退会処理を実行いたしました"
    redirect_to root_path
  end

  def favorites
    @user = User.find_by(id: params[:id])
    @current_user = current_user
    @favorites = Favorite.where(user_id: @current_user.id).page(params[:page]).per(8).order(created_at: :desc)
    @search_u = User.ransack(params[:q])
    @search_p = PostImage.ransack(params[:p])
  end

  def follow
    @user = User.find_by(id: params[:id])
    #@followings = Follow.where(user_id: @current_user.id)
    @posts = PostImage.where(user_id: [*current_user.following_ids]).page(params[:page]).per(8).order(created_at: :desc)
    @search_u = User.ransack(params[:q])
    @search_p = PostImage.ransack(params[:p])
  end
  def ensure_normal_user
    user = User.find(params[:id])
    if user.email == 'guest@exp.com'
      flash[:notice] = "ゲストユーザーは更新･削除できません。"
      redirect_to root_path
    end
  end

  def user_search
    @search_u = User.ransack(params[:q])
    @search_users = @search_u.result
  end


  private

  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end
end
