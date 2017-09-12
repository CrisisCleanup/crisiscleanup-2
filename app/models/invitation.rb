class Invitation < ApplicationRecord
  belongs_to :user
  validates :invitee_email, email_format: { message: "doesn't look like an email address" }
  before_create :generate_token
  before_create :add_expiration

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