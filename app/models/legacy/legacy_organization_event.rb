module Legacy
  class LegacyOrganizationEvent < ActiveRecord::Base
	belongs_to :legacy_event
	belongs_to :legacy_organization
	validates_uniqueness_of :legacy_event_id, scope: :legacy_organization_id
  end
end