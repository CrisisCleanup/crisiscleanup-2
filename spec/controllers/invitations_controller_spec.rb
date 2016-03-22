require 'rails_helper'
require 'spec_helper'

RSpec.describe InvitationsController, :type => :controller do

  before do |example|
    allow(controller).to receive(:current_user).and_return(@frank)
    org = FactoryGirl.create :legacy_organization
    @frank = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: org.id, accepted_terms: true, admin:true)
    @dhruv = User.create(name:'Dhruv', email:'Dhruv@gmail.com', password:'blue32blue32', legacy_organization_id: org.id, accepted_terms: true, admin:false)

    @invitation = Invitation.create(user_id:@frank.id, invitee_email:'Dhruv@aol.com', organization_id: org.id)
    @dhruv_invitation = Invitation.create(user_id:@dhruv.id, invitee_email:'Dhruv@aol.com', organization_id: org.id)
  end

  describe "it handles the token" do
    it 'redirects away from controller actions' do
      get :activate
      expect(response).to redirect_to(root_path)
    end

    it 'checks token' do
      get :activate,  :token => @invitation.token
      expect(response).to render_template('activate')
    end
  end

  describe "creates a user" do
    it 'verifies new user if invitee is an admin' do
      all = User.count
      post :sign_up,  :token => @invitation.token,:user => { email: "test@aol.com",password: 'blue32blue32', password_confirmation: "blue32blue32", name: "test", legacy_organization_id:@invitation.organization_id, referring_user_id:@invitation.user_id, accepted_terms: true }
      expect(User.count).to eq(all + 1)
    end

    it 'verifies new user if invitee is an admin' do
      all = User.count
      post :sign_up,  :token => @dhruv_invitation.token,:user => { email: "test@aol.com",password: 'blue32blue32', password_confirmation: "blue32blue32", name: "test", legacy_organization_id:@invitation.organization_id, referring_user_id:@invitation.user_id, accepted_terms: true }
      expect(User.count).to eq(all + 1)
    end
  end
end
