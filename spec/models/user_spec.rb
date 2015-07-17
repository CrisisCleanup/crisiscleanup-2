require 'rails_helper'
require 'spec_helper'

RSpec.describe User, type: :model do
    describe "associations" do
      it { should have_many :invitations }
      it { should belong_to :reference }
    

    end
    describe '.invitations and .invited_by' do
      org = FactoryGirl.create :legacy_organization 
      let(:frank) { User.create(name:'Frank', email:'frank@aol.com', password:'blue32blue32',legacy_organization_id:org.id) }
      let(:dhruv) { User.create(name:'Dhruv', email:'Dhruv@aol.com', password:'blue32blue32',legacy_organization_id:org.id) }
      before do
      	dhruv.update(referring_user_id:frank.id)
      end
      it 'USER.invited_by will show the reference' do
      	 expect(dhruv.invited_by.name).to eq('Frank')
      end

    end
    describe '.verify' do
      org = FactoryGirl.create :legacy_organization
      let(:frank) { User.create(name:'Frank', email:'frank@aol.com', password:'blue32blue32',legacy_organization_id:org.id) }  
      before do
        frank.verify!
      end
      it 'should be verified' do
         expect(frank.verified).to eq(true)
      end

    end
end