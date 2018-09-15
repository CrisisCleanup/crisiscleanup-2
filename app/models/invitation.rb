class Invitation < ActiveRecord::Base
  belongs_to :user
  validates :invitee_email, email_format: { message: "doesn't look like an email address" }
  before_create :generate_token
  before_create :add_expiration
  
  rails_admin do
    list do
      field :id do
        formatted_value do
          path = bindings[:view].show_path(model_name: 'Invitation', id: bindings[:object].id)
          bindings[:view].link_to(bindings[:object].id, path)
        end
      end
      field :user_id
      field :invitee_email
      field :invitation
      field :organization_id
      field :expiration
      field :activated
    end
  end
  
  def invitation
    return "<a href='https://www.crisiscleanup.org/invitations/activate?token=#{self.token}'>Invitation Link</a>".html_safe
  end
  
  protected
  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Invitation.exists?(token: random_token)
    end
  end

  def add_expiration
    self.expiration = Time.now + 7.days
  end
end