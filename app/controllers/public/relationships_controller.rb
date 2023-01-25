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

  def followers
    @user = User.find(params[:user_id])
    @users = @user.followers.page(params[:page]).per(10)
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

  def ensure_normal_user
    user = User.find(params[:user_id])
    if user.email == 'guest@exp.com'
      flash[:notice] = "ゲストユーザーはフォローできません。"
      redirect_to user_path(user.id)
    end
  end
end
