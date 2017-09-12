require 'rails_helper'
require 'spec_helper'

RSpec.describe Admin::LegacyContactsController, :type => :controller do


	before do |example|
	  org = FactoryGirl.create :legacy_organization 
	  @admin = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: true) 
	  @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
	end

	describe "Get #index" do
		context "with an admin user" do
			it "renders the index view" do
				allow(controller).to receive(:current_user).and_return(@admin)
				get :index
				expect(should).to render_template :index
			end

			it "populates an array of LegacyContacts" do
				allow(controller).to receive(:current_user).and_return(@admin)
				@contact = FactoryGirl.create :legacy_contact
				get :index 
				assigns(:contacts).should eq([@contact])
			end
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

			it "returns a new legacy contact" do
				allow(controller).to receive(:current_user).and_return(@admin)
				get :new
				assigns(:contact).first_name.should eq(nil)
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
			it "creates a new contact" do
				allow(controller).to receive(:current_user).and_return(@admin)
				expect {
					post :create, params: {legacy_legacy_contact: FactoryGirl.attributes_for(:legacy_contact)}
				}.to change(Legacy::LegacyContact, :count).by(1)
			end

			it "redirects to the contact index" do
				allow(controller).to receive(:current_user).and_return(@admin)
				post :create, params: {legacy_legacy_contact: FactoryGirl.attributes_for(:legacy_contact)}
				response.should redirect_to :admin_legacy_contacts
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
			it "renders the edit view with the correct contact" do
				allow(controller).to receive(:current_user).and_return(@admin)
				contact = FactoryGirl.create :legacy_contact
				get :edit, params: {id: contact}
				expect(should).to render_template :edit
			end

			it "assigns the requested contact to @contact" do
				allow(controller).to receive(:current_user).and_return(@admin)
				contact = FactoryGirl.create :legacy_contact
				get :edit, params: {id: contact}
				expect(should).to render_template :edit
			end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				contact = FactoryGirl.create :legacy_contact
				get :edit, params: {id: contact}
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				contact = FactoryGirl.create :legacy_contact
				get :edit, params: {id: contact}
				expect(should).to redirect_to "/login"
			end
		end

	end
	describe "Put #update" do
		context "with an admin user" do
			it "locates the correct contact" do
				allow(controller).to receive(:current_user).and_return(@admin)
				contact = FactoryGirl.create :legacy_contact
				put :update, params: {id: contact, legacy_legacy_contact: FactoryGirl.attributes_for(:legacy_contact)}
		      	assigns(:contact).should eq(contact)  
			end
			context "with correct attributes" do
				it "changes the contacts attributes" do
					@contact = FactoryGirl.create :legacy_contact
					allow(controller).to receive(:current_user).and_return(@admin)
					put :update, params: {id: @contact, legacy_legacy_contact: FactoryGirl.attributes_for(:legacy_contact, first_name: "Larry", last_name: "Smith")}
					@contact.reload
					@contact.first_name.should eq("Larry")
					@contact.last_name.should eq("Smith")
				end

				it "redirects the updated contact" do
					@contact = FactoryGirl.create :legacy_contact
					allow(controller).to receive(:current_user).and_return(@admin)
					put :update, params: {id: @contact, legacy_legacy_contact: FactoryGirl.attributes_for(:legacy_contact, first_name: "Larry", last_name: "Smith")}
					expect(response).to redirect_to :admin_legacy_contacts
				end
			end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				contact = FactoryGirl.create :legacy_contact
				put :update, params: {id: contact}
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				contact = FactoryGirl.create :legacy_contact
				post :create, params: {id: contact}
				expect(should).to redirect_to "/login"
			end
		end
	end

end