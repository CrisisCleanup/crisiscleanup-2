require 'rails_helper'
require 'spec_helper'

# We are importing these from an old DB right?
# Maybe our validations should be loose, to make sure we recieve all data

module Legacy
  describe LegacyOrganization do
    describe "associations" do
      it { should have_many :legacy_events }
      it { should have_many :legacy_contacts }
      it { should have_many :users }
      it { should validate_uniqueness_of :name}

    end
    
    describe "validations" do
      subject { Legacy::LegacyOrganization.new }
      it { should have_valid(:city).when("New York") }
   
    end
    # this is where we describe model methods
    describe '.model_method_one' do
 		
    end
    describe '.model_method_two' do
 		
    end
  end
end
