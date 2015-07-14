require 'rails_helper'
require 'spec_helper'

RSpec.describe InvitationList, type: :model do
    describe "attributes" do
      let(:frank) { User.create(name:'Frank', email:'frank@aol.com', password:'blue32blue32') }
      let(:good) { InvitationList.new("frank@aol.com,dhruv@aol.com", frank)}
      let(:empty) {  InvitationList.new('', frank)}
      let(:bad) {  InvitationList.new('1,2,3,4,5', frank)}

 	  it 'should not be valid if it is instantiated with an empty string' do
        expect(empty).to_not be_valid
        expect(good).to be_valid
        expect(bad).to be_valid
      end
      it 'should have a ready attribute for good emails, and a reject attribute for bad ones' do
       	good.prepare!
      	bad.prepare!
      	expect(good.ready.count).to eq(2)
        expect(bad.rejected.count).to be(5)
     end
    end

end