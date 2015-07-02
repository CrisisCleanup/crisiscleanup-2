module Legacy
  class LegacyOrganization < ActiveRecord::Base
      has_many :legacy_organization_events
 	  has_many :legacy_events, through: :legacy_organization_events
  	  has_many :legacy_contacts,
	    inverse_of: :legacy_organization
  end
end