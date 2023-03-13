class Public::UsersController < ApplicationController
  before_action :ensure_normal_user, only: %i[withdrawal update edit follow]
  before_action :user_search
  before_action :is_matching_login_user, only:[:edit, :update]

  def show
    @user = User.find(params[:id])
    @post_images = @user.post_images.page(params[:page]).per(18).order(created_at: :desc)
    @current_user = current_user
    @search_u = User.ransack(params[:q])
    @search_users = @search_u.result
    @search_p = PostImage.ransack(params[:p])
    @search_post_images = @search_p.result
    @currentRoomUser = RoomUser.where(user_id: @current_user)  #current_userが既にルームに参加しているか判断
    @receiveUser = RoomUser.where(user_id: @user.id)  #他の@userがルームに参加しているか判断

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

  def edit
    @user = User.find(params[:id])
    @current_user = current_user
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      if admin_signed_in?
        flash[:notice] = "編集が完了いたしました"
        redirect_to admin_user_path(@user.id)
      else
        flash[:notice] = "編集が完了いたしました"
        redirect_to user_path(@user.id)
      end
    else
      redirect_to edit_user_path(@user.id)
    end
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
    @favorites = Favorite.where(user_id: @current_user.id).page(params[:page]).per(18).order(created_at: :desc)
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
      flash[:notice] = "ゲストユーザーは編集･退会できません。"
      redirect_to user_path(user.id)
    end
  end

  def user_search
    @search_u = User.ransack(params[:q])
    @search_users = @search_u.result
    @search_p = PostImage.ransack(params[:q])
  end


  private

  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end

  def is_matching_login_user
    user_id = params[:id].to_i
    unless user_id == current_user.id
      redirect_to post_images_path
    end
  end

end