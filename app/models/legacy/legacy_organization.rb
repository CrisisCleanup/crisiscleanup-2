module Legacy
  class LegacyOrganization < ActiveRecord::Base
  	  self.per_page = 500
  	  has_paper_trail
      has_many :legacy_organization_events
 	  has_many :legacy_events, through: :legacy_organization_events
  	  has_many :users,
  	  	inverse_of: :legacy_organization
  	  has_many :legacy_contacts,
	    inverse_of: :legacy_organization
	  validates_presence_of :name, :address,:city
    accepts_nested_attributes_for :legacy_contacts, allow_destroy: true
  
    def verify!(current_user)
     if self.update(org_verified: true, is_active:true)
      true
     else
      false
     end
    end
  end
end 			
			
