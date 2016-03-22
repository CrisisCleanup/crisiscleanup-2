require 'rails_helper'
require 'spec_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many :invitations }
    it { should belong_to :reference }
  end

  describe "org validation" do
    let(:frank) { User.new(name:'Frank', email:'frank@aol.com', password:'blue32blue32', accepted_terms: true) }
    let(:dhruv) { User.new(name:'Dhruv', email:'Dhruv@aol.com', password:'blue32blue32', accepted_terms: true, admin:true) }

    it "should validate org id if i am not an admin" do
      expect(frank.valid?).to eq(false)
    end
    it "should not validate org id if i am not an admin" do
      expect(dhruv.valid?).to eq(true)
    end
  end

  describe '.invitations and .invited_by' do
    org = FactoryGirl.create(:legacy_organization, name: Faker::Name.name, email: Faker::Internet.email)
    let(:frank) { User.create(name:'Frank', email:'frank@aol.com', password:'blue32blue32', legacy_organization_id:org.id, accepted_terms: true) }
    let(:dhruv) { User.create(name:'Dhruv', email:'Dhruv@aol.com', password:'blue32blue32', legacy_organization_id:org.id, accepted_terms: true) }

    before do
      dhruv.update(referring_user_id:frank.id)
    end
    it 'USER.invited_by will show the reference' do
      expect(dhruv.invited_by.name).to eq('Frank')
    end

  end
end
