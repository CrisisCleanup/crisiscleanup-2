module Legacy
  class LegacyOrganization < ActiveRecord::Base
  	  has_paper_trail
      has_many :legacy_organization_events
 	  has_many :legacy_events, through: :legacy_organization_events
  	  has_many :users,
  	  	inverse_of: :legacy_organization
  	  has_many :legacy_contacts,
	    inverse_of: :legacy_organization
	  validates_presence_of :longitude, :latitude, :name, :password, :permissions, :timestamp_signup

  end
end 			
			
