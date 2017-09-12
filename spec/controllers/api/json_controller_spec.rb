require 'rails_helper'
require 'spec_helper'

RSpec.describe Api::JsonController, :type => :controller do

  before do
    org = FactoryGirl.create :legacy_organization
    @admin = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: true)
    @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false)
    @event = FactoryGirl.create :legacy_event
    mock_geocoding!
    @site = FactoryGirl.create :legacy_site, legacy_event_id: @event.id
  end

  describe "POST #update_legacy_site_status" do
    # This is definitely not what we want for an api controller.
    context "without a user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(nil)
        post :update_legacy_site_status, params: {id: @site.id}
        expect(should).to redirect_to "/login"
      end
    end

    # This is what we want
    context "with unauthenticated user" do
      it 'returns a 401'
    end

    # And this
    context "with unauthorized user" do
      it 'returns a 403'
    end

    context "when site status changes from 'Open, unassigned' and it is unclaimed" do
      it "is claimed_by user's organization" do
        @site.status = 'Open, unassigned'
        @site.claimed_by = nil
        @site.save
        allow(controller).to receive(:current_user).and_return(@user)
        post :update_legacy_site_status, params: {id: @site.id, status: 'Open, assigned'}
        expect(response).to be_success

        json = JSON.parse(response.body)

        expect(json['status']).to eq('success')
        expect(json['claimed_by']).to eq(@user.legacy_organization_id)
      end
    end

    context "when site status is changed" do
      it "returns site_status equal to new status" do
        allow(controller).to receive(:current_user).and_return(@user)
        post :update_legacy_site_status, params: {id: @site.id, status: 'Open, partially completed'}
        expect(response).to be_success

        json = JSON.parse(response.body)

        expect(json['status']).to eq('success')
        expect(json['site_status']).to eq('Open, partially completed')
      end
    end
  end

  describe "POST #claim_legacy_site" do
    # This is definitely not what we want for an api controller.
    context "without a user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(nil)
        post :claim_legacy_site, params: {id: @site.id}
        expect(should).to redirect_to "/login"
      end
    end

    # This is what we want
    context "with unauthenticated user" do
      it 'returns a 401'
    end

    # And this
    context "with unauthorized user" do
      it 'returns a 403'
    end

    context "when site is claimed by user's organization" do
      it "returns unclaimed" do
        @site.claimed_by = @user.legacy_organization_id
        @site.save
        allow(controller).to receive(:current_user).and_return(@user)
        post :claim_legacy_site, params: {id: @site.id}
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
        post :claim_legacy_site, params: {id: @site.id}
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
        post :claim_legacy_site, params: {id: @site.id}
        expect(response).to be_success

        json = JSON.parse(response.body)

        expect(json['status']).to eq('success')
        expect(json['claimed_by']).to eq(@user.legacy_organization_id)
      end
    end
  end
end