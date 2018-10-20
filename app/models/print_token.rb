class PrintToken < ActiveRecord::Base
  belongs_to :user
  belongs_to :legacy_site, :class_name => "Legacy::LegacySite"
  belongs_to :legacy_organization, :class_name => "Legacy::LegacyOrganization"
  before_create :generate_token
  before_create :add_expiration   
  
  def token_url
    return "https://www.crisiscleanup.org/z/#{self.token}".html_safe
  end 
    
  protected
  def generate_token
    self.token = loop do
      random_token = rand(36**8).to_s(36)
      break random_token unless PrintToken.exists?(token: random_token)
    end
  end

  def add_expiration
    self.token_expiration = Time.now + 14.days
  end
end
