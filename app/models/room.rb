class Room < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :room_users, dependent: :destroy
  has_many :users, through: :room_users
  def get_other_users(current_user)
    users.not.where(current_user.id)
  end
end
