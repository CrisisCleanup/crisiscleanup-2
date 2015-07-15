module Legacy
  class LegacyContact < ActiveRecord::Base
  	  has_paper_trail
  	  belongs_to :legacy_organization,
    	inverse_of: :legacy_contacts 
  end
end