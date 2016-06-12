require 'rails_helper'
require 'spec_helper'

RSpec.describe Admin::DashboardController, :type => :controller do


	before do |example|
	  org = FactoryGirl.create(:legacy_organization, name: 'beta')
	  org2 = FactoryGirl.create(:legacy_organization, name: 'alpha') 
	  @admin = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: true) 
	  @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
	end

	describe "Get #index" do
		context "with a current_user" do
			it "renders the index view" do
				allow(controller).to receive(:current_user).and_return(@admin)
				get :index
				expect(should).to render_template :index
			end

			it "returns organizations in alphabetical order" do
				allow(controller).to receive(:current_user).and_return(@admin)
				get :index
				assigns(:orgs).map{|org| org.name}.should eq(['alpha','beta'])
			end



		end

		context "without a current_user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				get :index
				expect(should).to redirect_to "/dashboard"
			end
		end
	end
end