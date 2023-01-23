class Public::RoomsController < ApplicationController
  before_action :ensure_normal_user, only: %i[create show index]
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
      @another_user = (@RoomUsers.where.not(id: current_user.id).to_a)[0] #自分ではない相手の情報
    else
      redirect_back(fallback_location: root_path)
    end
  end

  def ensure_normal_user
    user = current_user
    if user.email == 'guest@exp.com'
      flash[:notice] = "ゲストユーザーはDMできません。"
      redirect_to user_path(user.id)
    end
  end
  
  def index
    
  end

  private

  def join_room_params
    params.require(:room_user).permit(:user_id, :room_id).merge(room_id: @room.id)
  end
end
