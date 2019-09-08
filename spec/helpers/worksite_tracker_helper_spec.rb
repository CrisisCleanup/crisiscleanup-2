require "rails_helper"

RSpec.describe WorksiteTrackerHelper, :type => :helper do
  
  describe "WorksiteTrackerHelper" do
    
    it "generate_token" do
      expect(helper.generate_token).to be_kind_of(String)
    end
      
    it "generate_qr" do
      expect(helper.generate_qr("http://example.com")).to be_kind_of(RQRCode::QRCode)
    end
    
  end
  
end