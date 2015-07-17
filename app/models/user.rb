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
  def verify!
    self.update(verified:true)
  end
  def org
    # this is where we'll add new orgs too
    self.legacy_organization
    # self.legacy_organization || self.organization
  end 
  def self.todays_login_count
  	count = User.where("DATE(last_sign_in_at) = ?", Date.today).count
  end
end
