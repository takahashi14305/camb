class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :post_images, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  has_one_attached :profile_image
  has_many :favorites, dependent: :destroy

  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followings, through: :relationships, source: :followed
  has_many :followers, through: :reverse_of_relationships, source: :follower

  has_many :room_users, dependent: :destroy
  has_many :rooms, through: :room_users
  has_many :messages, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1, maximum: 10 }
  validates :introduction, length: { maximum: 95 }

  def get_profile_image(width, height)
    unless profile_image.attached?
      file_path = Rails.root.join('app/assets/images/no_image.jpg')
      profile_image.attach(io: File.open(file_path), filename: 'default-image.jpg', content_type: 'image/jpeg')
    end
    profile_image.variant(resize_to_limit: [width, height]).processed
  end

  def active_for_authentication?
    super && (is_deleted == false)
  end

  def self.guest
    find_or_create_by!(email: 'guest@exp.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = "ゲスト"
      # user.confirmed_at = Time.now  # Confirmable を使用している場合は必要
      # 例えば name を入力必須としているならば， user.name = "ゲスト" なども必要
    end
  end

  def follow(user_id)
    relationships.create(followed_id: user_id)
  end
    # フォローを外すときの処理
  def unfollow(user_id)
    relationships.find_by(followed_id: user_id).destroy
  end
    # フォローしているか判定
  def following?(user)
    followings.include?(user)
  end

  # userに相手のuser情報を入れるとすでに部屋があるか確認してくれる
  def has_room?(user)
    get_room(user) != nil
  end

  # userに相手のuser情報を入れるとすでに部屋がある場合、部屋のレコードを返してくれる
  def get_room(user)
    ids = rooms.pluck(:id)
    Room.left_joins(:room_users).where(id: ids).find_by(room_users: {user_id: user.id})
  end

end
