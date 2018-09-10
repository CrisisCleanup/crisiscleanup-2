require 'rails_helper'

RSpec.describe Worker::DashboardController, :type => :controller do


	before do |example|
	  org = FactoryGirl.create :legacy_organization 
	  # @admin = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: true) 
	  @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
	end

	describe "Get #index" do
		context "with a current_user" do
			it "renders the index view" do
				allow(controller).to receive(:current_user).and_return(@user)
				get :index
				expect(should).to render_template :index
			end
		end

		context "without a current_user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				get :index
				expect(should).to redirect_to "/login"
			end
		end
	end

	describe "Get #redeploy_form" do
		context "with a current_user" do
			it "renders the index view" do
				allow(controller).to receive(:current_user).and_return(@user)
				get :redeploy_form
				expect(should).to render_template :redeploy_form
			end
		end

		context "without a current_user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				get :redeploy_form
				expect(should).to redirect_to "/login"
			end
		end
	end
end