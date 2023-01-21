class Public::RoomsController < ApplicationController
  before_action :ensure_normal_user, only: %i[create show]
  before_action :authenticate_user!

  def create
    @room = Room.create
    user = User.find(params[:room][:user_id])
    @joinCurrentUser = RoomUser.create(user_id: current_user.id, room_id: @room.id)
    @joinUser = RoomUser.create(room_id: @room.id, user_id: user.id)
    redirect_to room_path(@room.id)
  end

  def show
    @room = Room.find(params[:id])
    if RoomUser.where(user_id: current_user.id, room_id: @room.id).present?
      @messages = @room.messages
      @message = Message.new
      @RoomUsers = @room.users
    else
      redirect_back(fallback_location: root_path)
    end
  end

  def ensure_normal_user
    user = current_user
    if user.email == 'guest@exp.com'
      flash[:notice] = "ゲストユーザーはチャットできません。"
      redirect_to root_path
    end
  end

  private

  def join_room_params
    params.require(:room_user).permit(:user_id, :room_id).merge(room_id: @room.id)
  end
end
