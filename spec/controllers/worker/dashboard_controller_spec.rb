require 'rails_helper'

RSpec.describe Worker::DashboardController, :type => :controller do


	before do |example|
	  @org = FactoryGirl.create :legacy_organization 
	  @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: @org.id, admin: false) 
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
	
	describe "Get #incident_chooser" do
		
		context "with a user that has permissions to event" do
			before do |example|
				@event = FactoryGirl.create :legacy_event
				@org.legacy_events << @event
			end
			
			it "can switch incidents if user has permissions to event" do
				allow(controller).to receive(:current_user).and_return(@user)
				request.headers["Referer"] = "/dashboard"
				get :incident_chooser, :id => @event.id
				expect(controller).to set_flash
				expect(controller).to set_flash[:notice]
				expect(controller).to set_flash[:notice].to(/Now viewing #{@event.name}/).now
				expect(should).to redirect_to "/dashboard"
			end
		end
		
		context "with a user that does not have permissions to event" do
			it "alert user that no permissions exist to event" do
				allow(controller).to receive(:current_user).and_return(@user)
				request.headers["Referer"] = "/dashboard"
				get :incident_chooser
				expect(controller).to set_flash
				exp_regex = /You don't have permission to view that event/
				expect(controller).to set_flash[:alert].to(exp_regex).now			
				expect(should).to redirect_to "/dashboard"
			end
		end
		
		context "with an admin" do
			before do |example|
				@admin = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: @org.id, admin: true) 
				@event = FactoryGirl.create :legacy_event
				@org.legacy_events << @event			
			end
			
			it "allows admin to switch to any incident" do
				allow(controller).to receive(:current_user).and_return(@admin)
				request.headers["Referer"] = "/dashboard"
				get :incident_chooser, :id => @event.id
				expect(controller).to set_flash
				expect(controller).to set_flash[:notice].to(/Now viewing #{@event.name}/).now				
				expect(should).to redirect_to "/dashboard"
			end
		end
		
	end
	
	describe "redeploy_request" do
		
		context "with user whose org already has access to event" do
			before do |example|
				@event = FactoryGirl.create :legacy_event
				@org.legacy_events << @event
			end
			
			it "notifies user of existing access" do
				allow(controller).to receive(:current_user).and_return(@user)
				get :redeploy_request, :Event => @event.id
				expect(controller).to set_flash
				expect(controller).to set_flash[:alert]
				expect(flash[:alert]).to be_present
				expect(flash[:alert]).to include("#{@event.name}")
				regex = /[\w\s]+#{@event.name}[\w\s.-]+/
				expect(controller).to set_flash[:alert].to(regex).now
				expect(should).to redirect_to "/worker/dashboard"
			end
		end
		
		context "with user whose org that does not have access to event" do
			before do |example|
				@admin = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: @org.id, admin: true) 
				@event = FactoryGirl.create :legacy_event
			end
			
			it "notifies user redeploy request" do
    			allow_any_instance_of(InvitationMailer).to receive(:send_redeploy_alert).and_return(nil)
				allow(controller).to receive(:current_user).and_return(@user)
				get :redeploy_request, :Event => @event.id
				expect(flash[:notice]).to be_present
				expect(flash[:notice]).to include("#{@event.name}")
				expect(should).to redirect_to "/worker/dashboard"
			end
		end
	end
		
end