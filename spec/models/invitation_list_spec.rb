require 'rails_helper'
require 'spec_helper'

RSpec.describe InvitationList, type: :model do
    describe "attributes" do
      org = FactoryGirl.create :legacy_organization 
      frank = FactoryGirl.create(:user, legacy_organization_id: org.id)
      good = InvitationList.new("frank@aol.com,dhruv@aol.com", frank)
      empty = InvitationList.new('', frank)
      bad = InvitationList.new('1,2,3,4,5', frank)

 	  it 'should not be valid if it is instantiated with an empty string' do
        expect(empty).to_not be_valid
        expect(good).to be_valid
        expect(bad).to be_valid
      end
    it 'should have a ready attribute for good emails, and a reject attribute for bad ones' do
    	expect(good.ready.count).to eq(2)
      expect(bad.rejected.count).to be(5)
   end
     # test the separation 
  end
end