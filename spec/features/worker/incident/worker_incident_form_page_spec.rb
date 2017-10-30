require 'rails_helper'

describe "Worker incident form page", :type => :feature, :js => true do

  before(:each) do
    form = FactoryGirl.create(:form)
    @site = FactoryGirl.build(:legacy_site)
    email = sign_in_with_user
    @p = Pages::WorkerIncidentFormPage.new
    @p.go_to(1)
  end

  it "presents validation warning for county field" do
    @site.county = nil
    @p.fill_form(@site)
    @p.save_form
    expect(page).to have_selector('#legacy_legacy_site_county + small', visible: true)
  end

  it "presents validation warning for phone1 field" do
    @site.phone1 = nil
    @p.fill_form(@site)
    @p.save_form
    expect(page).to have_selector('#legacy_legacy_site_phone1 + small', visible: true)
  end

end
