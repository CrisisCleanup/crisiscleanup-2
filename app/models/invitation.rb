class Invitation < ActiveRecord::Base
  belongs_to :user
  validates :invitee_email, email_format: { message: "doesn't look like an email address" }
  before_create :generate_token

  protected
  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Invitation.exists?(token: random_token)
    end
  end
end