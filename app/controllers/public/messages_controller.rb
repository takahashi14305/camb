class Public::MessagesController < ApplicationController
 before_action :authenticate_user!

  def create
    if RoomUser.where(user_id: current_user.id, room_id: params[:message][:room_id]).present?
      @message = Message.create(message_params)
      redirect_to room_path(@message.room_id)
    else
      flash[:alert] = "メッセージの送信に失敗しました。"
    end
  end

  private

  def message_params
    params.require(:message).permit(:user_id, :room_id, :body).merge(user_id: current_user.id)
  end
end

