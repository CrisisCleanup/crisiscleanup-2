require 'rails_helper'
require 'spec_helper'

RSpec.describe RequestInvitation, type: :model do
    describe "validations" do
	  it { should validate_presence_of :name}
	  it { should validate_presence_of :email}
	  it { should validate_uniqueness_of :email}
    end

    describe "invited!" do
    	let(:request){ FactoryGirl.create :request_invitation }
    	it "should set invited to true" do
    		RequestInvitation.invited!(request.email)
    		request.reload
    		expect(request.invited).to be(true)
    	end
    end

    describe "user_created!" do
    	let(:request){ FactoryGirl.create :request_invitation }
    	it "should set user_created to true" do
    		RequestInvitation.user_created!(request.email)
    		request.reload
    		expect(request.user_created).to be true
    	end

    end
end