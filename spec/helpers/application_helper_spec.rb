require "rails_helper"

RSpec.describe ApplicationHelper, :type => :helper do
  
	before do |example|
	  org = FactoryGirl.create :legacy_organization 
	  @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
	end 
    
  describe "ApplicationHelper" do
    
  #   it "check_admin" do
		# 	allow(helper).to receive(:current_user).and_return(@user)
		# 	expect(helper).to redirect_to('/login')
  #     helper.check_admin?
  #   end
      
    it "random_password" do
      expect(helper.random_password).to be_kind_of(String)
    end
      
    it "worksite_statuses" do
      expect(helper.worksite_statuses).to be_kind_of(Array)
    end     
    
    it "get_state_list" do
      expect(helper.get_state_list).to be_kind_of(Array)
    end
    
  end
  
end