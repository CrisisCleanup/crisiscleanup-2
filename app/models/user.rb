class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :invitations
  belongs_to :reference, class_name: "User", foreign_key: "referring_user_id"

  def invited_by
  	self.reference
  end

end
