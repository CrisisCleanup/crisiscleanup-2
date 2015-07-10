module Legacy
  class LegacyOrganization < ActiveRecord::Base
      has_many :legacy_organization_events
 	  has_many :legacy_events, through: :legacy_organization_events
  	  has_many :legacy_contacts,
	    inverse_of: :legacy_organization
	  validates_presence_of :activate_by,:activated_at,:activation_code,:address,:city,:email,:is_active,:latitude,:longitude,:name,:password,:permissions,:phone,:physical_presence,:publish,:reputable,:state,:timestamp_signup,:work_area,:zip_code

  end
end 			
			
