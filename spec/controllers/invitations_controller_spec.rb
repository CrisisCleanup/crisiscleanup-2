require 'rails_helper'
require 'spec_helper'

RSpec.describe InvitationsController, :type => :controller do

  before do |example|
    allow(controller).to receive(:current_user).and_return(@frank)
    org = FactoryGirl.create :legacy_organization 
    @frank = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: org.id) 
    
    @invitation = Invitation.create(user_id:@frank.id, invitee_email:'Dhruv@aol.com', organization_id: org.id) 
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
end


