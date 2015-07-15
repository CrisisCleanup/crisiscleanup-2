module Legacy
  class LegacySite < ActiveRecord::Base
      has_paper_trail
  	  
      belongs_to :legacy_event
  	  validates_presence_of :address,:blurred_latitude,:blurred_longitude,:case_number,:city,:latitude,:longitude,:name
  	

  	  def claimed_by_org
  	  	LegacyOrganization.find(self.claimed_by)
  	  end
  	  def reported_by_org
  	  	LegacyOrganization.find(self.reported_by)
  	  end

  end
end