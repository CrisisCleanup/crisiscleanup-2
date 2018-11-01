class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  include Legacy

  has_paper_trail

  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :invitations, inverse_of: :user
  has_many :audits
  belongs_to :legacy_organization, :class_name => "Legacy::LegacyOrganization"
  belongs_to :reference, class_name: "User", foreign_key: "referring_user_id"
  validates_presence_of :legacy_organization_id, :if => :is_not_admin?
  validates_presence_of :accepted_terms
  before_save :set_terms_timestamp
  
  rails_admin do
    list do
      field :id do
        formatted_value do
          path = bindings[:view].show_path(model_name: 'User', id: bindings[:object].id)
          bindings[:view].link_to(bindings[:object].id, path)
        end
      end
      field :name
      field :legacy_organization
      field :allow_caller_access
      field :mobile
      field :email
      field :referring_user do
        formatted_value do
          path = bindings[:view].show_path(model_name: 'User', id: bindings[:object].referring_user_id)
          bindings[:view].link_to(bindings[:object].referring_user_id, path)
        end
      end     
      field :created_at
      field :last_sign_in_at
    end
    
  end
  
  def is_caller
    self.allow_caller_access
  end
  
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

  def events
    events = []
    Legacy::LegacyOrganizationEvent.where(legacy_organization_id: self.legacy_organization.id).each do |leo|
      events.push(leo.legacy_event_id)
    end
    events
  end

  def set_terms_timestamp
    self.accepted_terms_timestamp = DateTime.now
  end
end
