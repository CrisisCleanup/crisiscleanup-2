require 'rails_helper'
require 'spec_helper'

RSpec.describe Admin::LegacyEventsController, :type => :controller do


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

			it "populates an array of LegacyEvents" do
				allow(controller).to receive(:current_user).and_return(@admin)
				@event = FactoryGirl.create :legacy_event
				get :index 
				assigns(:events).should_not eq(nil)
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

			it "returns a new legacy event" do
				allow(controller).to receive(:current_user).and_return(@admin)
				get :new
				assigns(:event).name.should eq(nil)
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
			it "creates a new event" do
				allow(controller).to receive(:current_user).and_return(@admin)
				expect {
					post :create, params: {legacy_legacy_event: FactoryGirl.attributes_for(:legacy_event)}
				}.to change(Legacy::LegacyEvent, :count).by(1)
			end

			it "redirects to the event index" do
				allow(controller).to receive(:current_user).and_return(@admin)
				post :create, params: {legacy_legacy_event: FactoryGirl.attributes_for(:legacy_event)}
				response.should redirect_to :admin_legacy_events
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
			it "renders the edit view with the correct event" do
				allow(controller).to receive(:current_user).and_return(@admin)
				event = FactoryGirl.create :legacy_event
				get :edit, params: {id: event}
				expect(should).to render_template :edit
			end

			it "assigns the requested event to @event" do
				allow(controller).to receive(:current_user).and_return(@admin)
				event = FactoryGirl.create :legacy_event
				get :edit, params: {id: event}
				expect(should).to render_template :edit
			end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				event = FactoryGirl.create :legacy_event
				get :edit, params: {id: event}
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				event = FactoryGirl.create :legacy_event
				get :edit, params: {id: event}
				expect(should).to redirect_to "/login"
			end
		end

	end
	describe "Put #update" do
		context "with an admin user" do
			it "locates the correct event" do
				allow(controller).to receive(:current_user).and_return(@admin)
				event = FactoryGirl.create :legacy_event
				put :update, params: {id: event, legacy_legacy_event: FactoryGirl.attributes_for(:legacy_event)}
		      	assigns(:event).should eq(event)  
			end
			context "with correct attributes" do
				it "changes the events attributes" do
					@event = FactoryGirl.create :legacy_event
					allow(controller).to receive(:current_user).and_return(@admin)
					put :update, params: {id: @event, legacy_legacy_event: FactoryGirl.attributes_for(:legacy_event, case_label: "ZZ")}
					@event.reload
					@event.case_label.should eq("ZZ")
				end

				it "redirects the updated event" do
					@event = FactoryGirl.create :legacy_event
					allow(controller).to receive(:current_user).and_return(@admin)
					put :update, params: {id: @event, legacy_legacy_event: FactoryGirl.attributes_for(:legacy_event, case_label: "ZZ")}
					expect(response).to redirect_to :admin_legacy_events
				end
			end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				event = FactoryGirl.create :legacy_event
				put :update, params: {id: event}
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				event = FactoryGirl.create :legacy_event
				post :create, params: {id: event}
				expect(should).to redirect_to "/login"
			end
		end
	end

end