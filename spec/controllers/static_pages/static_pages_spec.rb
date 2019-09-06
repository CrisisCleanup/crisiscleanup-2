require 'rails_helper'
require 'spec_helper'

RSpec.describe StaticPagesController, :type => :controller do
	describe "Get #index" do
		
		before do |example|
		  @org = FactoryGirl.create :legacy_organization 
		  @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: @org.id, admin: false) 
		end	
		
		it "renders the index view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :index
			expect(should).to render_template :index
		end
		
		it "renders the dashboard view" do
			allow(controller).to receive(:current_user).and_return(@user)
			get :index
			expect(should).to redirect_to '/dashboard'
		end	
	end
	
	describe "Get #request_incident" do
		
		before do |example|
		  @org = FactoryGirl.create :legacy_organization 
		  @admin = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: @org.id, admin: true) 
		  @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: @org.id, admin: false) 
		end	
		
		it "sends incident requests" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :request_incident
			expect(should).to redirect_to '/'
			expect(flash[:notice]).to eq("Your request has been received")
		end
	end	
	
	describe "Get #home" do
		it "renders the index view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :home
			expect(should).to render_template :index
		end
	end	

	describe "Get #about" do
		it "renders the about view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :about
			expect(should).to render_template :about
		end
	end

	describe "Get #public_map" do
		it "renders the public_map view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :public_map
			expect(should).to render_template :public_map
		end
	end

	describe "Get #privacy" do
		it "renders the privacy view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :privacy
			expect(should).to render_template :privacy
		end
	end

	describe "Get #terms" do
		it "renders the terms view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :terms
			expect(should).to render_template :terms
		end
	end

	describe "Get #signup" do
		it "renders the signup view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :signup
			expect(should).to render_template :signup
		end
	end

	describe "Get #new_incident" do
		it "renders the new_incident view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :new_incident
			expect(should).to render_template :new_incident
		end
	end

	describe "Get #redeploy" do
		it "renders the redeploy view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :redeploy
			expect(should).to render_template :redeploy
		end
	end
	
	describe "Get #donate" do
		it "redirect to patreon" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :donate
			expect(should).to redirect_to "https://www.patreon.com/crisiscleanup"
		end
	end	
	
	describe "Get #voad" do
		it "render" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :voad
			expect(should).to render_template 'application_sidebar'
		end
	end		
	
	describe "Get #government" do
		it "render" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :government
			expect(should).to render_template 'application_sidebar'
		end
	end		
	
	describe "Get #voad" do
		it "render" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :voad
			expect(should).to render_template 'application_sidebar'
		end
	end		
	
	describe "Get #volunteer" do
		it "render" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :volunteer
			expect(should).to render_template 'application_sidebar'
		end
	end		
	
	describe "Get #survivor" do
		it "render" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :survivor
			expect(should).to render_template 'application_sidebar'
		end
	end		
	
	describe "Get #training" do
		it "render" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :training
			expect(should).to render_template 'application_sidebar'
		end
	end		
end