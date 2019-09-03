require 'rails_helper'
require 'spec_helper'

RSpec.describe PhoneOutbound, type: :model do
  describe "associations" do
    it { should belong_to :legacy_site }
  end
  
  describe 'select_next_phone_outbound_for_user' do

  	context "Group 1" do
  		
  		before do |example|
  			@user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', admin: false)
  		end
  		
  		it "will return the same phone_outbound record" do
  			phone_outbound = FactoryGirl.create(:phone_outbound_1)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user(@user.id, 'English')
  			expect(phone_outbound_record).to eq(phone_outbound)
  		end
  	
   		it "will not return phone_outbound record if case_updated_at is recent" do
  			FactoryGirl.create(:phone_outbound_incomplete, case_updated_at: DateTime.now.to_date)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user(@user.id, 'English')
  			expect(phone_outbound_record).to be_nil
  		end 		
  		
     	it "will return phone_outbound record if completion is less than 1.0" do
  			po = FactoryGirl.create(:phone_outbound_incomplete, completion: 0.5)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user(@user.id, 'English')
  			expect(phone_outbound_record).to eq(po)
  		end 		
  		
      it "will return phone_outbound record if completion is nil/null" do
  			po = FactoryGirl.create(:phone_outbound_incomplete, completion: nil)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user(@user.id, 'English')
  			expect(phone_outbound_record).to eq(po)
  		end  		
  		
    	it "will not return phone_outbound record if completion is 1.0" do
  			FactoryGirl.create(:phone_outbound_incomplete, completion: 1.0)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user(@user.id, 'English')
  			expect(phone_outbound_record).to be_nil
  		end  		
  		
     	it "will not return phone_outbound record if completion is greater than 1.0" do
  			FactoryGirl.create(:phone_outbound_incomplete, completion: 1.25)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user(@user.id, 'English')
  			expect(phone_outbound_record).to be_nil
  		end 		
  		
      it "will not return phone_outbound record if already in progress (phone_outbound_status)" do
  			po = FactoryGirl.create(:phone_outbound_incomplete)
  			pos = FactoryGirl.create(:phone_outbound_status_1, outbound_id: po.id)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user(@user.id, 'English')
  			expect(phone_outbound_record).to be_nil
  		end 		
  	end	
  end
  
  describe 'select_next_phone_outbound_for_user_with_state_filter' do
  	fixtures :phone_area_codes

  	context "Group 1" do
  		
  		before do |example|
  			@user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', admin: false)
  			@state_filter = "Oklahoma"
  		end
  		
  		it "will return the same phone_outbound record" do
  			phone_outbound = FactoryGirl.create(:phone_outbound_1)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user_with_state_filter(@user.id, @state_filter, 'English')
  			expect(phone_outbound_record).to eq(phone_outbound)
  		end
  		
    	it "will not return phone_outbound record if state dnis does not match" do
  			FactoryGirl.create(:phone_outbound_1, dnis1_area_code: 800)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user_with_state_filter(@user.id, @state_filter, 'English')
  			expect(phone_outbound_record).to be_nil
  		end 		
  	
   		it "will not return phone_outbound record if case_updated_at is recent" do
  			FactoryGirl.create(:phone_outbound_1, case_updated_at: DateTime.now.to_date)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user_with_state_filter(@user.id, @state_filter, 'English')
  			expect(phone_outbound_record).to be_nil
  		end 		
  		
     	it "will return phone_outbound record if completion is less than 1.0" do
  			po = FactoryGirl.create(:phone_outbound_1, completion: 0.5)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user_with_state_filter(@user.id, @state_filter, 'English')
  			expect(phone_outbound_record).to eq(po)
  		end 		
  		
      it "will return phone_outbound record if completion is nil/null" do
  			po = FactoryGirl.create(:phone_outbound_1, completion: nil)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user_with_state_filter(@user.id, @state_filter, 'English')
  			expect(phone_outbound_record).to eq(po)
  		end  		
  		
    	it "will not return phone_outbound record if completion is 1.0" do
  			FactoryGirl.create(:phone_outbound_1, completion: 1.0)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user_with_state_filter(@user.id, @state_filter, 'English')
  			expect(phone_outbound_record).to be_nil
  		end  		
  		
     	it "will not return phone_outbound record if completion is greater than 1.0" do
  			FactoryGirl.create(:phone_outbound_1, completion: 1.25)
  		  phone_outbound_record = PhoneOutbound.select_next_phone_outbound_for_user_with_state_filter(@user.id, @state_filter, 'English')
  			expect(phone_outbound_record).to be_nil
  		end 		
  	end	
  end 
end
