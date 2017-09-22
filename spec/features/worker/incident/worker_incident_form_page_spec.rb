require 'rails_helper'

describe "Worker incident form page", :type => :feature, :js => true do

  before(:each) do
    form = FactoryGirl.create(:form)
    @site = FactoryGirl.build(:legacy_site)
    email = sign_in_with_user
    @p = Pages::WorkerIncidentFormPage.new
    @p.go_to(1)
  end

  it "allows user to complete and submit form for new site" do
    @p.fill_out_form(@site)
    @p.save_form

    # puts current_url
    # require 'pry'; binding.pry

    expect(page).to have_selector('#alert-container', visible: true)

    visit "/worker/incident/1/sites"

    expect(page).to have_content(@site.name)

    site = Legacy::LegacySite.find(1)
    expect(site.name).to eq(@site.name)
    expect(site.phone1).to eq(@site.phone1)
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

  it "allows user to complete and submit form for new site2" do
    @p.fill_out_form(@site)
    @p.save_form

    expect(page).to have_selector('#alert-container', visible: true)

    visit "/worker/incident/1/sites"

    expect(page).to have_content(@site.name)

    site = Legacy::LegacySite.find(1)
    expect(site.name).to eq(@site.name)
    expect(site.phone1).to eq(@site.phone1)
  end

end
