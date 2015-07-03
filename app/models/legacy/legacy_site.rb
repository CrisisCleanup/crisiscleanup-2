module Legacy
  class LegacySite < ActiveRecord::Base
  	  belongs_to :legacy_event
  	  def claimed_by_org
  	  	LegacyOrganization.find(self.claimed_by)
  	  end
  	  def reported_by_org
  	  	LegacyOrganization.find(self.reported_by)
  	  end

  end
end