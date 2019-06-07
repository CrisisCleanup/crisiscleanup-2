require 'rails_helper'
require 'spec_helper'

RSpec.describe PhoneOutbound, type: :model do
  describe "associations" do
    it { should belong_to :legacy_site }
  end
  
  describe 'select_next_phone_outbound_for_user' do
  	fixtures :phone_area_codes

  	context "Group 1" do
  		
  		before do |example|
  			@user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', admin: false)
  		end
  		
  		it "will return the same phone_outbound record" do
  			phone_outbound = FactoryGirl.create(:phone_outbound_1)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user(@user.id)
  			expect(phone_outbound_record).to eq(phone_outbound)
  		end
  	
   		it "will not return phone_outbound record if case_updated_at is recent" do
  			phone_outbound = FactoryGirl.create(:phone_outbound_incomplete, case_updated_at: DateTime.now.to_date)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user(@user.id)
  			expect(phone_outbound_record).to be_nil
  		end 		
  	end	
  end
end
