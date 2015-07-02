require 'rails_helper'
require 'spec_helper'

# We are importing these from an old DB right?
# Maybe our validations should be loose, to make sure we recieve all data

module Legacy
  describe LegacyContact do
    describe "associations" do
      it { should belong_to :legacy_organization }
    end
    
    # this is where we describe model methods
    describe '.model_method_one' do
 		
    end
    describe '.model_method_two' do
 		
    end
  end
end
