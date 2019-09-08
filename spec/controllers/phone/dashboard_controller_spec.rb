require 'rails_helper'

RSpec.describe Phone::DashboardController, :type => :controller do

  describe "Get #index" do
    before do |example|
      org = FactoryGirl.create :legacy_organization
      @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
    end	
    
    context "with a current_user" do
      it "renders the done view because no phone_outbound records exist" do
        allow(controller).to receive(:current_user).and_return(@user)
        get :index
        expect(should).to render_template :done
      end
    end
    
    context "with PhoneOutbound records" do
      before do |example|
        @phone_outbound = PhoneOutbound.create()
      end
      
      it "renders index view" do
        allow(controller).to receive(:current_user).and_return(@user)
        get :index
        expect(should).to render_template :index		
      end
    end
  end
  
  describe "Existing phone_outbound_status id" do
    fixtures :phone_status
    
    before do |example|
      org = FactoryGirl.create :legacy_organization
      @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
    end	
    
    context "with PhoneOutbound records" do
      before do |example|
        allow(controller).to receive(:current_user).and_return(@user)
        @phone_outbound = FactoryGirl.create(:phone_outbound_1)
        @phone_outbound_status = FactoryGirl.create(:phone_outbound_status_1, 
          outbound_id: @phone_outbound.id)
      end
      
      it "renders done view" do
        get :index, phone_outbound_status_id: @phone_outbound_status.id,
          phone_status_id: 16 # No Answer: Voicemail full
        expect(should).to render_template :done		
      end
      
    end
    
    context "phone complete" do
      before do |example|
        allow(controller).to receive(:current_user).and_return(@user)
        data = {}
        data["status_notes"] = "Alpha"
        @site = FactoryGirl.create :legacy_site, data: data
        @phone_outbound = FactoryGirl.create(:phone_outbound_1, 
          worksite_id: @site.id)
        @phone_outbound_status = FactoryGirl.create(:phone_outbound_status_1, 
          outbound_id: @phone_outbound.id)
      end
      
      it "updates legacy site notes" do
        get :index, phone_outbound_status_id: @phone_outbound_status.id,
          phone_status_id: 16, # No Answer: Voicemail full
          status_notes: "Omega"
        expect(should).to render_template :done		
        site = Legacy::LegacySite.find_by_id(@site.id)
        expect(site.data["status_notes"]).to eq("Alpha\nOmega")
      end
      
    end    
    
   context "selected_phone_status completion is >= 1.00" do
      before do |example|
        allow(controller).to receive(:current_user).and_return(@user)
        # data = {}
        # data["status_notes"] = "Alpha"
        # @site = FactoryGirl.create :legacy_site, data: data
        @phone_outbound = FactoryGirl.create(:phone_outbound_1)
        @phone_outbound_status = FactoryGirl.create(:phone_outbound_status_1, 
          outbound_id: @phone_outbound.id)
      end
      
      it "update phone_outbound_status" do
        get :index, phone_outbound_status_id: @phone_outbound_status.id,
          phone_status_id: 1
        expect(should).to render_template :done		
      end
      
    end   
  end  
    
    
  describe "State filters" do
    fixtures :phone_area_codes
    
    context "Test State Filter - nil" do
      before do |example|
        org = FactoryGirl.create(:legacy_organization)
        @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false)
        @phone_outbound = PhoneOutbound.create()
      end
      
      it "renders index view" do
        allow(controller).to receive(:current_user).and_return(@user)
        get :index
        expect(should).to render_template :index		
      end
    end	
    
    context "Test State Filter - None" do
      before do |example|
        org = FactoryGirl.create(:legacy_organization, call_state_filter: 'None')
        @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false)
        @phone_outbound = PhoneOutbound.create()
      end
      
      it "renders index view" do
        allow(controller).to receive(:current_user).and_return(@user)
        get :index
        expect(should).to render_template :index		
      end
    end	
    
    context "Test State Filter - Empty String" do
      before do |example|
        org = FactoryGirl.create(:legacy_organization, call_state_filter: '')
        @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false)
        @phone_outbound = PhoneOutbound.create()
      end
      
      it "renders index view" do
        allow(controller).to receive(:current_user).and_return(@user)
        get :index
        expect(should).to render_template :done		
      end
    end		
    
    context "Test State Filter - With specific state - no more available" do
      before do |example|
        org = FactoryGirl.create(:legacy_organization, call_state_filter: 'Oklahoma')
        @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false)
        @phone_outbound = PhoneOutbound.create()
      end
      
      it "renders index view" do
        allow(controller).to receive(:current_user).and_return(@user)
        get :index
        expect(should).to render_template :done		
      end
    end	
    
    context "Verify PhoneAreaCode count" do
      
      it "has the correct count" do
        expect(PhoneAreaCode.count(:all)).to be > 300
      end
      
    end
    
    context "Test State Filter - With specific state - returns record that is associated with state" do
      
      before do |example|
        org = FactoryGirl.create(:legacy_organization, call_state_filter: 'Oklahoma')
        @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false)
        @phone_outbound = FactoryGirl.create(:phone_outbound_1)
      end
      
      it "renders index view" do
        allow(controller).to receive(:current_user).and_return(@user)
        get :index
        expect(should).to render_template :index		
      end
    end	
    
    context "Test State Filter - With specific state - dnis2 - returns record that is associated with state" do
      
      before do |example|
        org = FactoryGirl.create(:legacy_organization, call_state_filter: 'Oklahoma')
        @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false)
        @phone_outbound = FactoryGirl.create(:phone_outbound_2)
      end
      
      it "renders index view" do
        allow(controller).to receive(:current_user).and_return(@user)
        get :index
        expect(should).to render_template :index		
      end
    end	
    
  end
  
  describe "Get #change_call_language" do
    before do |example|
      org = FactoryGirl.create :legacy_organization
      @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
      allow(controller).to receive(:current_user).and_return(@user)
    end	
    
    context "valid params" do
      it "deletes outbound status and sets language filter" do
        # @phone_outbound = FactoryGirl.create(:phone_outbound_1)
        @phone_outbound_status = FactoryGirl.create(:phone_outbound_status_1)
        get :change_call_language,
          phone_outbound_status_id: @phone_outbound_status.id,
          call_language_filter: 'English'
        expect(should).to redirect_to '/phone/dashboard'
        expect(session[:call_language_filter]).to eq('English')
        check = PhoneOutboundStatus.find_by_id(@phone_outbound_status.id)
        expect(check).to be_nil
      end
    end
    
  end
  
  describe "Get #cancel" do
    
    before do |example|
      org = FactoryGirl.create :legacy_organization
      @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
      allow(controller).to receive(:current_user).and_return(@user)
    end	
    
    context "valid params" do
      it "deletes outbound status on cancel" do
        @phone_outbound_status = FactoryGirl.create(:phone_outbound_status_1)
        get :cancel,
          phone_outbound_status_id: @phone_outbound_status.id
        expect(should).to redirect_to '/worker/dashboard'
        check = PhoneOutboundStatus.find_by_id(@phone_outbound_status.id)
        expect(check).to be_nil
      end
    end
    
  end  
  
  describe "Get #done" do
    
    before do |example|
      org = FactoryGirl.create :legacy_organization
      @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
      allow(controller).to receive(:current_user).and_return(@user)
    end	
    
    context "existing session" do
      it "set to existing session" do
        session[:call_language_filter] = 'Spanish'
        get :done
        expect(response).to be_success
        expect(assigns(:call_language_filter)).to eq('Spanish')
      end
    end
    
    context "non-existent session" do
      it "defaults to English" do
        get :done
        expect(response).to be_success
        expect(assigns(:call_language_filter)).to eq('English')
      end
    end    
    
  end    

end