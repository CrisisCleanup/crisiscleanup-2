class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  include Legacy

  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :invitations, inverse_of: :user
  belongs_to :legacy_organization, :class_name => "Legacy::LegacyOrganization"
  belongs_to :reference, class_name: "User", foreign_key: "referring_user_id"
  
  
  def invited_by
  	self.reference
  end

end
