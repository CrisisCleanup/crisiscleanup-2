require 'rails_helper'
require 'spec_helper'

# We are importing these from an old DB right?
# Maybe our validations should be loose, to make sure we recieve all data

module Legacy
  describe LegacyOrganizationEvent do

    describe "validations" do
      subject { Legacy::LegacyEvent.new }
      it { should have_valid(:name).when("Dinosaur in New York") }
   
    end
    # this is where we describe model methods
    describe '.model_method_one' do
 		
    end
    describe '.model_method_two' do
 		
    end
  end
end
