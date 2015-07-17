module Legacy
  class LegacyContact < ActiveRecord::Base
  	  self.per_page = 500
  	  has_paper_trail
  	  belongs_to :legacy_organization,
    	inverse_of: :legacy_contacts 
  end
end