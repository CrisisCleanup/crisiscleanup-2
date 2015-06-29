module Legacy
  class LegacyEvent < ActiveRecord::Base
  	  has_many :legacy_organization_events
 	  has_many :legacy_organizations, through: :legacy_organization_events
  end
end