require 'rails_helper'
require 'spec_helper'

RSpec.describe Invitation, type: :model do
    describe "associations" do
      it { should belong_to :user }
    end
    describe '.generate token' do
      let(:frank) { User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32') }
      before do
        Invitation.create(user_id:frank.id, invitee_email:'Dhruv@aol.com') 
      end
      it 'should have a random token, because of before create' do
        expect(frank.invitations.first.token).not_to be_empty
      end
      it 'should increase franks invitation count' do
        expect(frank.invitations.count).to eq(1)
      end
    end
end