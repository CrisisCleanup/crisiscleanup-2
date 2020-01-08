class RedeployRequest < ActiveRecord::Base
  belongs_to :legacy_organization, :class_name => "Legacy::LegacyOrganization"
  belongs_to :legacy_event, :class_name => "Legacy::LegacyEvent"
  before_create :generate_token

  rails_admin do
    list do
      field :id do
        formatted_value do
          path = bindings[:view].show_path(model_name: 'RedeployRequest', id: bindings[:object].id)
          bindings[:view].link_to(bindings[:object].id, path)
        end
      end
      field :legacy_organization
      field :legacy_event
      field :accept_url
      field :accepted
      field :accepted_by do
        formatted_value do
          path = bindings[:view].show_path(model_name: 'User', id: bindings[:object].accepted_by)
          bindings[:view].link_to(bindings[:object].accepted_by, path)
        end
      end
    end
  end

  def accept_url
    return "https://www.crisiscleanup.org/redeploy_request/accept?token=#{self.token}"
  end


  def accept
    return "<a href='#{self.accept_url}'>Approve</a>".html_safe
  end

  protected
  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless RedeployRequest.exists?(token: random_token)
    end
  end

end
