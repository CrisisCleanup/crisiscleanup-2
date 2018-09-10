require 'rails_helper'

describe "Worker incident map page", :type => :feature, :js => true do

  before(:each) do
    @site = FactoryGirl.create(:legacy_site)
    @user = sign_in_with_user
    @p = Pages::WorkerIncidentMapPage.new
    @p.go_to(1)
  end

  # it "presents correct infobox for site" do
  #
  #   # puts current_url
  #   # require 'pry'; binding.pry
  #
  #   @p.get_site_marker(@site.case_number)
  #   expect(page).to have_selector('#map-infobox', visible: true)
  #
  #   expect(find("#infobox-caseNumber").text).to eq(@site.case_number)
  #   expect(find("#infobox-phone1").text).to eq(@site.phone1)
  #   expect(find("#infobox-name").text).to eq(@site.name)
  #   expect(find("#infobox-status > select").value).to eq(@site.status)
  #
  # end
  #
  # it "can select site and print order" do
  #
  #   @p.get_site_marker(@site.case_number)
  #   expect(page).to have_selector('#map-infobox', visible: true)
  #
  #   @p.click_infobox_print
  #
  #   window_name = "CrisisCleanup - Print Case Number #{@site.case_number}"
  #
  #   within_window(-> { page.title == window_name }) { current_url.should match /print\/#{@site.id}/}
  #
  # end

  # it "allows user to claim site", :js => true do
  #
  #   @p.get_site_marker(@site.case_number)
  #   expect(page).to have_selector('#map-infobox', visible: true)
  #
  #   expect(page).to have_selector('#infobox-claim', visible: true)
  #   @p.click_claim_site
  #   expect(page).to have_selector('#infobox-unclaim', visible: true)
  #
  #   s = Legacy::LegacySite.find_by(case_number: @site.case_number)
  #   expect(s.claimed_by).to eq(@user.id)

    # expect(page).to have_selector('#infobox-unclaim', visible: true)
    #
    # find('#map-search-btn').trigger('click')
    # @p.get_site_marker(@site.case_number)
    # expect(page).to have_selector('#map-infobox', visible: true)
    #
    # @p.click_unclaim_site
    #
    # expect(page).to have_selector('#infobox-claim', visible: true)
    #
    # s2 = Legacy::LegacySite.find_by(case_number: @site.case_number)
    # expect(s2.claimed_by).to be_nil

  # end

  # it "allows user to unclaim site" do
  #
  #   @site.claimed_by = @user.legacy_organization_id
  #   @site.save!
  #
  #   @p.get_site_marker(@site.case_number)
  #   expect(page).to have_selector('#map-infobox', visible: true)
  #
  #   expect(page).to have_selector('#infobox-unclaim', visible: true)
  #   @p.click_unclaim_site
  #   sleep(3)
  #   expect(page).to have_selector('#infobox-claim', visible: true)
  #
  #   s = Legacy::LegacySite.find_by(case_number: @site.case_number)
  #   expect(s.claimed_by).to be_nil
  #
  # end

end
