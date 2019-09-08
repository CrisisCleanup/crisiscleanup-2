require 'rails_helper'
require 'spec_helper'

RSpec.describe Admin::LegacyOrganizationsController, :type => :controller do


	before do |example|
	  org = FactoryGirl.create(:legacy_organization, name: Faker::Name.name, email: Faker::Internet.email)
	  @admin = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: true) 
	  @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
	  @organization = FactoryGirl.create(:legacy_organization, name: Faker::Name.name)
	end

	describe "Get #index" do
		context "with an admin user" do
			it "renders the index view" do
				allow(controller).to receive(:current_user).and_return(@admin)
				get :index
				expect(should).to render_template :index
			end

			# it "populates an array of LegacyOrganizations" do
			# 	allow(controller).to receive(:current_user).and_return(@admin)
			# 	@organization = FactoryGirl.create :legacy_organization
			# 	get :index 
			# 	assigns(:orgs).should eq([@organization])
			# end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				get :index
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				get :index
				expect(should).to redirect_to "/login"
			end
		end
	end
	describe "Get #new" do
		context "with an admin user" do
			it "renders the new view" do
				allow(controller).to receive(:current_user).and_return(@admin)
				get :new
				expect(should).to render_template :new
			end

			it "returns a new legacy organization" do
				allow(controller).to receive(:current_user).and_return(@admin)
				get :new
				assigns(:org).name.should eq(nil)
			end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				get :new
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				get :new
				expect(should).to redirect_to "/login"
			end
		end

	end

	describe "Post #create" do
		context "with an admin user" do
			# it "creates a new organization" do
			# 	allow(controller).to receive(:current_user).and_return(@admin)
			# 	expect {
			# 		post :create, legacy_legacy_organization: FactoryGirl.attributes_for(:legacy_organization, name: Faker::Name.name, email: Faker::Internet.email, accepted_terms: true)
			# 	}.to change(Legacy::LegacyOrganization, :count).by(1)
			# end

			it "redirects to the organization index" do
				allow(controller).to receive(:current_user).and_return(@admin)
				post :create, 
					legacy_legacy_organization: FactoryGirl.attributes_for(:legacy_organization, name: Faker::Name.name, email: Faker::Internet.email, accepted_terms: true)
				expect(should).to render_template :new
			end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				post :create
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				post :create
				expect(should).to redirect_to "/login"
			end
		end
	end

	describe "Get #edit" do
		context "with an admin user" do
			it "renders the edit view with the correct organization" do
				allow(controller).to receive(:current_user).and_return(@admin)
				organization = FactoryGirl.create(:legacy_organization, name: Faker::Name.name, email: Faker::Internet.email)
				get :edit, id: organization
				expect(should).to render_template :edit
			end

			it "assigns the requested organization to @organization" do
				allow(controller).to receive(:current_user).and_return(@admin)
				organization = FactoryGirl.create(:legacy_organization, name: Faker::Name.name, email: Faker::Internet.email)
				get :edit, id: organization
				expect(should).to render_template :edit
			end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				organization = FactoryGirl.create(:legacy_organization, name: Faker::Name.name, email: Faker::Internet.email)
				get :edit, id: organization
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				organization = FactoryGirl.create(:legacy_organization, name: Faker::Name.name, email: Faker::Internet.email)
				get :edit, id: organization
				expect(should).to redirect_to "/login"
			end
		end

	end
	
	describe "Put #update" do
		context "with an admin user" do
			it "locates the correct organization" do
				allow(controller).to receive(:current_user).and_return(@admin)
				organization = FactoryGirl.create(:legacy_organization, name: Faker::Name.name, email: Faker::Internet.email)
				put :update, id: organization, legacy_legacy_organization: FactoryGirl.attributes_for(:legacy_organization)
		      	assigns(:org).should eq(organization)  
			end
			context "with correct attributes" do
				it "changes the organizations attributes" do
					@organization = FactoryGirl.create(:legacy_organization, name: "ZZ", email: Faker::Internet.email)
					allow(controller).to receive(:current_user).and_return(@admin)
					put :update, id: @organization, legacy_legacy_organization: FactoryGirl.attributes_for(:legacy_organization, name: "ZZ")
					@organization.reload
					@organization.name.should eq("ZZ")
				end

				it "redirects the updated organization" do
					@organization = FactoryGirl.create(:legacy_organization, name: "ZZ", email: Faker::Internet.email)
					allow(controller).to receive(:current_user).and_return(@admin)
					put :update, id: @organization, legacy_legacy_organization: FactoryGirl.attributes_for(:legacy_organization, case_label: "ZZ", name: Faker::Name.name, email: Faker::Internet.email)
					expect(response).to redirect_to :admin_legacy_organizations
				end
			end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				organization = FactoryGirl.create(:legacy_organization, name: Faker::Name.name, email: Faker::Internet.email)
				put :update, id: organization
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				organization = FactoryGirl.create(:legacy_organization, name: "ZZ", email: Faker::Internet.email)
				post :create, id: organization
				expect(should).to redirect_to "/login"
			end
		end
	end
	
	describe "Get #verify" do
		context "with an admin user" do
			it "redirects to" do
				allow(controller).to receive(:current_user).and_return(@admin)
				organization = FactoryGirl.create(:legacy_organization, name: Faker::Name.name, email: Faker::Internet.email)
				get :verify, id: organization.id
				expect(should).to redirect_to admin_dashboard_index_path
			end
		end
	end	

end