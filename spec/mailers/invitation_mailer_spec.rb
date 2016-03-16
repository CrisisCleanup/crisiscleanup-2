require 'rails_helper'
require 'spec_helper'
RSpec.describe InvitationMailer do

  describe "Sends Invitations" do
    before(:each) do 
       org = FactoryGirl.create :legacy_organization 
      @frank = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id:org.id) 
      @invitation = Invitation.create(user_id:@frank.id, invitee_email:'Dhruv@aol.com', organization_id: org.id) 
      @mail = InvitationMailer.send_invitation(@invitation,"http://www.crisisCleanup.org")
    end
    it 'renders the subject' do
      expect(@mail.subject).to eq("Frank has invited you to join Crisis Cleanup")
    end
 
    it 'renders the receiver email' do
      expect(@mail.to).to eq(["Dhruv@aol.com"])
    end
 
    it 'expect token to appear in the email' do
      expect(@mail.body.encoded).to match( @invitation.token )
    end
  end
end
