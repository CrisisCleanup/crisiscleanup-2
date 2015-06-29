require 'rails_helper'
require 'spec_helper'

module Legacy
  describe LegacyEvent do
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
