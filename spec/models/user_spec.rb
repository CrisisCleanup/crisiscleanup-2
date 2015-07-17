require 'rails_helper'
require 'spec_helper'

RSpec.describe User, type: :model do
    describe "associations" do
      it { should have_many :invitations }
      it { should belong_to :reference }
      it { should belong_to Legacy::LegacyOrganization }

    end
    describe '.invitations and .invited_by' do
      let(:frank) { User.create(name:'Frank', email:'frank@aol.com', password:'blue32blue32') }
      let(:dhruv) { User.create(name:'Dhruv', email:'Dhruv@aol.com', password:'blue32blue32') }
      before do
      	dhruv.update(referring_user_id:frank.id)
      end
      it 'USER.invited_by will show the reference' do
      	 expect(dhruv.invited_by.name).to eq('Frank')
      end

    end
end