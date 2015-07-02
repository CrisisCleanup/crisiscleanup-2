module Legacy
  class LegacyContact < ActiveRecord::Base
  	  belongs_to :legacy_organization,
    	inverse_of: :legacy_contacts 
  end
end