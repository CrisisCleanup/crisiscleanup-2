require 'rails_helper'

RSpec.describe Phone::DashboardController, :type => :controller do


	before do |example|
	  org = FactoryGirl.create :legacy_organization 
	  # @admin = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: true) 
	  @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
	end

	describe "Get #index" do
		context "with a current_user" do
			it "renders the done view because no phone_outbound records exist" do
				allow(controller).to receive(:current_user).and_return(@user)
				get :index
				expect(should).to render_template :done
			end
		end

	end

end