class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :invitations, class_name: "User", foreign_key: "referring_user_id" 
  belongs_to :reference, class_name: "User", foreign_key: "referring_user_id"

  def invited_by
  	self.reference
  end

  def self.todays_login_count
  	count = User.where("DATE(last_sign_in_at) = ?", Date.today).count
  end
end
