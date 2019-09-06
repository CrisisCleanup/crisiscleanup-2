require 'rails_helper'
require 'spec_helper'

RSpec.describe AdminMailer do

  describe "Sends send_registration_alert" do
    before(:each) do
      @org = FactoryGirl.create :legacy_organization
      @frank = User.create( name:'Frank', email: 'Frank@aol.com', password: 'blue32blue32', legacy_organization_id: @org.id, accepted_terms: true )
      @event = FactoryGirl.create :legacy_event
      @org.legacy_events << @event
      
      @mail = AdminMailer.send_registration_alert(@frank, @org)
    end

    it 'renders the subject' do
      expect(@mail.subject).to eq("#{@org.name} has registered for Crisis Cleanup")
    end

    it 'renders the receiver email' do
      expect(@mail.to).to eq([@frank.email])
    end
  end
  
  describe "Sends send_user_registration_alert" do
    before(:each) do
      @org = FactoryGirl.create :legacy_organization
      @frank = User.create( name:'Frank', email: 'Frank@aol.com', password: 'blue32blue32', legacy_organization_id: @org.id, accepted_terms: true )
      @event = FactoryGirl.create :legacy_event
      @org.legacy_events << @event
      
    end

    it 'renders the subject' do
      @mail = AdminMailer.send_user_registration_alert(@frank, @org)
      expect(@mail.subject).to eq("#{@frank.name} has registered for Crisis Cleanup with #{@org.name}")
    end
    
    it 'renders the subject' do
      @mail = AdminMailer.send_user_registration_alert(@frank, nil)
      expect(@mail.subject).to eq("#{@frank.name} has registered for Crisis Cleanup with the Admin")
    end   

    it 'renders the receiver email' do
      @mail = AdminMailer.send_user_registration_alert(@frank, @org)
      expect(@mail.to).to eq([@frank.email])
    end
    
  end  
end
