require 'rails_helper'
require 'spec_helper'

RSpec.describe InvitationsController, :type => :controller do

  before do |example|
    @frank = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32') 
    @invitation = Invitation.create(user_id:@frank.id, invitee_email:'Dhruv@aol.com') 
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


