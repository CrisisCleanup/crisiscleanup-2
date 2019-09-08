require 'rails_helper'
require 'spec_helper'

RSpec.describe Invitation, type: :model do
  describe "associations" do
    it { should belong_to :user }
  end
  
  let(:org){ FactoryGirl.create :legacy_organization }
  let(:frank) { User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id:org.id, accepted_terms: true) }
    
  before do
    @invitation = Invitation.create(user_id:frank.id, invitee_email:'Dhruv@aol.com', organization_id: org.id)
  end   

  describe '.generate token' do

    it 'should have a random token, because of before create' do
      expect(frank.invitations.first.token).not_to be_empty
    end

    it 'should increase franks invitation count' do
      expect(frank.invitations.count).to eq(1)
    end
  end
  
  describe "invitation" do
    
    it 'test' do
      Invitation.rails_admin.list
      # Invitation.rails_admin.list.field(:id).formatted_value
    end
    
    it 'generates the correct invitation link' do
      link = @invitation.invitation
      exp_link = "<a href='https://www.crisiscleanup.org/invitations/activate?token=#{@invitation.token}'>Invitation Link</a>"
      expect(link).to eq(exp_link)
    end
  end
end
