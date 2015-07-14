module Legacy
  class LegacyOrganization < ActiveRecord::Base
      has_many :legacy_organization_events
 	  has_many :legacy_events, through: :legacy_organization_events
  	  has_many :legacy_contacts,
	    inverse_of: :legacy_organization
	  validates_presence_of :is_active, :longitude, :latitude, :name, :password, :permissions, :timestamp_signup, :created_at, :updated_at

  end
end 			
			
