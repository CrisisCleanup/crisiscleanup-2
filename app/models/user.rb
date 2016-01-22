class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  include Legacy

  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :invitations, inverse_of: :user
  belongs_to :legacy_organization, :class_name => "Legacy::LegacyOrganization"
  belongs_to :reference, class_name: "User", foreign_key: "referring_user_id"
  validates_presence_of :legacy_organization_id, :if => :is_not_admin?
  
  def invited_by
  	self.reference
  end

  def is_not_admin?
    !self.admin 
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
