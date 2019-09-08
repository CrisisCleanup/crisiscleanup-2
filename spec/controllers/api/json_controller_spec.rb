require 'rails_helper'
require 'spec_helper'

RSpec.describe Api::JsonController, :type => :controller do

  before do
    org = FactoryGirl.create :legacy_organization
    @admin = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: true)
    @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false)
    PaperTrail.controller_info[:whodunnit] = @user.id
    @event = FactoryGirl.create :legacy_event
    mock_geocoding!
    @site = FactoryGirl.create :legacy_site, legacy_event_id: @event.id
  end
  
  describe "POST #site" do
    context "without a user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(nil)
        post :site, id: @site.id
        expect(should).to redirect_to "/login"
      end
    end 
    
    context "site exists" do
      it "returns site" do
        allow(controller).to receive(:current_user).and_return(@user)
        post :site, id: @site.id
        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json['id']).to eq(@site.id)
        expect(json['case_number']).to eq(@site.case_number)
      end
    end      
    
    context "no site exists" do
      it "returns error" do
        allow(controller).to receive(:current_user).and_return(@user)
        post :site, id: 1000
        
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['msg']).to include('Site with id')
      end
    end     
  end

  describe "POST #update_legacy_site_status" do
    # This is definitely not what we want for an api controller.
    context "without a user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(nil)
        post :update_legacy_site_status, id: @site.id
        expect(should).to redirect_to "/login"
      end
    end

    context "when site status changes from 'Open, unassigned' and it is unclaimed" do
      it "is claimed_by user's organization" do
        @site.status = 'Open, unassigned'
        @site.claimed_by = nil
        @site.save
        allow(controller).to receive(:current_user).and_return(@user)
        post :update_legacy_site_status, id: @site.id, status: 'Open, assigned'
        expect(response).to be_success

        json = JSON.parse(response.body)

        expect(json['status']).to eq('success')
        expect(json['claimed_by']).to eq(@user.legacy_organization_id)
      end
    end

    context "when site status is changed" do
      it "returns site_status equal to new status" do
        allow(controller).to receive(:current_user).and_return(@user)
        post :update_legacy_site_status, id: @site.id, status: 'Open, partially completed'
        expect(response).to be_success

        json = JSON.parse(response.body)

        expect(json['status']).to eq('success')
        expect(json['site_status']).to eq('Open, partially completed')
      end
    end
    
    context "when status not included" do
      it "returns error message" do
        allow(controller).to receive(:current_user).and_return(@user)
        post :update_legacy_site_status, id: @site.id, status: 'Nonexistent status'

        json = JSON.parse(response.body)

        expect(json['status']).to eq('error')
        expect(json['msg']).to eq('Not a site status type')
      end
    end   
    
    context "when site does not exist" do
      it "returns error message" do
        allow(controller).to receive(:current_user).and_return(@user)
        post :update_legacy_site_status, id: 1000, status: 'Open, partially completed'

        json = JSON.parse(response.body)

        expect(json['status']).to eq('error')
        expect(json['msg']).to include('Site with id')
      end
    end    
  end

  describe "POST #claim_legacy_site" do
    # This is definitely not what we want for an api controller.
    context "without a user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(nil)
        post :claim_legacy_site, id: @site.id
        expect(should).to redirect_to "/login"
      end
    end

    context "when site is claimed by user's organization" do
      it "returns unclaimed" do
        @site.claimed_by = @user.legacy_organization_id
        @site.save
        allow(controller).to receive(:current_user).and_return(@user)
        post :claim_legacy_site, id: @site.id
        expect(response).to be_success

        json = JSON.parse(response.body)

        expect(json['status']).to eq('success')
        expect(json['claimed_by']).to eq(nil)
      end
    end

    context "when site is claimed by an organization other than the user's" do
      it "returns claimed_by current organization" do
        @site.claimed_by = @user.legacy_organization_id + 1
        @site.save
        allow(controller).to receive(:current_user).and_return(@user)
        post :claim_legacy_site, id: @site.id
        expect(response).to be_success

        json = JSON.parse(response.body)

        expect(json['status']).to eq('error')
      end
    end

    context "when site is unclaimed" do
      it "returns claimed_by user's organization" do
        @site.claimed_by = nil
        @site.save
        allow(controller).to receive(:current_user).and_return(@user)
        post :claim_legacy_site, id: @site.id
        expect(response).to be_success

        json = JSON.parse(response.body)

        expect(json['status']).to eq('success')
        expect(json['claimed_by']).to eq(@user.legacy_organization_id)
      end
    end
  end
  
  describe "POST #relocate_worksite_pin" do
    
    before do |example|
      allow(controller).to receive(:current_user).and_return(@user)
    end
    
    context "correct parameters to move worksite provided" do
      it "worksite is relocated" do
        expected_lat = 35.2 
        expected_long = 122.5
        post :relocate_worksite_pin,
          worksiteId: @site.id,
          zoomLevel: 25,
          latitude: expected_lat,
          longitude: expected_long
        
        json = JSON.parse(response.body)
        expect(json['status']).to eq('success')
        expect(json['msg']).to eq('Worksite pin relocated.')
        
        site = Legacy::LegacySite.first
        expect(site.latitude).to eq(expected_lat)
        expect(site.longitude).to eq(expected_long)
      end
    end
    
    context "non-existent worksite" do
      it "returns error message for non-existent worksite" do
        post :relocate_worksite_pin,
          worksiteId: 5,
          zoomLevel: 25
        
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['msg']).to eq('Could not find worksite.')
      end
    end    
    
    context "zoomLevel less than 20" do
      it "returns error message for zoom less than 20" do
        post :relocate_worksite_pin,
          zoomLevel: 19
        
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['msg']).to eq('Zoom level must be 20 or greater.')
      end
    end
    
  end
  
  describe "POST #move_worksite_to_incident" do
    
    before do |example|
      allow(controller).to receive(:current_user).and_return(@user)
      @event2 = FactoryGirl.create :legacy_event
    end
    
    context "correct parameters to move worksite provided" do
      it "worksite is moved to incident" do
        post :move_worksite_to_incident,
          worksiteId: @site.id,
          incidentId: @event2.id
        
        json = JSON.parse(response.body)
        expect(json['status']).to eq('success')
        expect(json['msg']).to eq('Site moved to incident.')
        
        site = Legacy::LegacySite.find(@site.id)
        expect(site.legacy_event_id).to eq(@event2.id)
        expect(site.case_number).to be_kind_of(String)
        expect(site.claimed_by).to be_nil
        expect(site.user_id).to be_nil
      end
    end
    
    context "non-existent worksite" do
      it "returns error message for non-existent worksite" do
        post :move_worksite_to_incident,
          worksiteId: 1000
          
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['msg']).to eq('Could not find worksite.')
      end
    end    
    
    context "non-existent event" do
      it "returns error message for non-existent event" do
        post :move_worksite_to_incident,
          worksiteId: @site.id,
          incidentId: 1000
          
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['msg']).to eq('Could not find event.')
      end
    end     
    
    context "same event" do
      it "returns error message" do
        post :move_worksite_to_incident,
          worksiteId: @site.id,
          incidentId: @event.id
          
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['msg']).to eq('Not allowed to to move this site to its current incident again.')
      end
    end      
    
  end  
  
  describe "POST #incidents" do
    
    before do |example|
      allow(controller).to receive(:current_user).and_return(@user)
      @event2 = FactoryGirl.create :legacy_event
    end
    
    context "all" do
      it "returns all incidents" do
        post :incidents
        
        json = JSON.parse(response.body)
        expect(json['incidents'].length).to eq(2)
      end
    end
  end  
  
  describe "POST #site_history" do
    context "without a user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(nil)
        post :site_history, id: @site.id
        expect(should).to redirect_to "/login"
      end
    end 
    
    context "site exists" do
      before do |example|
        org = FactoryGirl.create :legacy_organization, name: 'org5321'
        @user = FactoryGirl.create :user
        PaperTrail.controller_info[:whodunnit] = @user.id
        @event = FactoryGirl.create :legacy_event
        mock_geocoding!
        @site = FactoryGirl.create :legacy_site, legacy_event_id: @event.id, user_id: @user.id
        @site.name = 'test'
        @site.save
      end
      
      with_versioning do
        it "returns site history" do
          allow(controller).to receive(:current_user).and_return(@user)
          post :site_history, id: @site.id
          expect(response).to be_success
          json = JSON.parse(response.body)
          expect(json['history'][@user.name]['versions'].length).to eq(2)
        end
      end
    end      
    
  end  
  
 describe "POST #map" do
    
    before do |example|
      allow(controller).to receive(:current_user).and_return(@user)
    end
    
    context "provide pin" do
      it "returns specific site" do
        get :map, event_id: @event.id, pin: @site.id, page: 1, limit: 100
        
        json = JSON.parse(response.body)
        expect(json['id']).to eq(@site.id)
        expect(json['case_number']).to eq(@site.case_number)
      end
    end
    
    context "provide no pin" do
      it "returns sites" do
        get :map, event_id: @event.id, page: 1, limit: 100
        
        json = JSON.parse(response.body)
        expect(json[0]['id']).to eq(@site.id)
        expect(json[0]['case_number']).to eq(@site.case_number)
      end
    end    
    
    context "bad params" do
      it "catches argument error" do
        get :map, event_id: @event.id, page: 'something', limit: 'something'
        json = JSON.parse(response.body)
        expect(json[0]['id']).to eq(@site.id)
        expect(json[0]['case_number']).to eq(@site.case_number)
      end
    end      
  end  
  
end