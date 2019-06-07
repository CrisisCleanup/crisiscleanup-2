require 'rails_helper'
require 'spec_helper'

RSpec.describe ApplicationController, :type => :controller do

  before do |example|
    org = FactoryGirl.create :legacy_organization
    @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, accepted_terms: true, admin: false)
  end

  describe "map_dashboard_mode" do
    it "be map_dashboard_mode if 'map' in url" do
      controller.env["REQUEST_URI"] = "http://something/map"
      expect(controller.map_dashboard_mode()).to be(true)
    end
    
    it "be map_dashboard_mode if 'form' in url" do
      controller.env["REQUEST_URI"] = "http://something/form"
      expect(controller.map_dashboard_mode()).to be(true)
    end   
    
    it "be map_dashboard_mode if 'edit' in url" do
      controller.env["REQUEST_URI"] = "http://something/edit"
      expect(controller.map_dashboard_mode()).to be(true)
    end   
  end
end