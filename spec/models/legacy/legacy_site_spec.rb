require 'rails_helper'
require 'spec_helper'

# We are importing these from an old DB right?
# Maybe our validations should be loose, to make sure we recieve all data

module Legacy
  describe LegacySite do
    describe "associations" do
      it { should belong_to :legacy_event }
    end

    # this is where we describe model methods
    describe '.claimed_by_org' do
 		it 'takes the claimed by id and returns its org' do
      @event = Legacy::LegacyEvent.first
	 		org = FactoryGirl.create :legacy_organization 
	 		site = FactoryGirl.create :legacy_site, reported_by: org.id, legacy_event_id: @event.id
	    	site.claimed_by = org.id
	    	expect(site.claimed_by_org).to be_a(Legacy::LegacyOrganization)
    	end
    end
    describe '.reported_by_org' do
 		it 'takes the claimed by id and returns its org' do
      @event = Legacy::LegacyEvent.first
	 		org = FactoryGirl.create :legacy_organization 
	 		site = FactoryGirl.create :legacy_site, reported_by: org.id, legacy_event_id: @event.id
	    	site.claimed_by = org.id
	    	expect(site.reported_by_org).to be_a(Legacy::LegacyOrganization)
    	end
    end
  end
end
