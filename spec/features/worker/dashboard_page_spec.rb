require 'rails_helper'

describe "View worker dashboard", :type => :feature, :js => true do

  before do
    email = sign_in_with_user
    @p = Pages::WorkerDashboardPage.new
  end

  it "loads a page with the proper main header" do
    @p.click_dashboard_link
    expect(page).to have_content 'My Work Dashboard'
  end

  it "user can click my organization quick link" do
    @p.click_quick_link("My Organization")

    expect(page).to have_content 'Users in My Organization'
    expect(page).to have_content 'Pending Invitations for My Organization'
  end

  it "user can click contacts quick link" do
    @p.click_quick_link("Contacts")

    expect(page).to have_content 'Contacts'
    expect(page).to have_content 'All Organizations'
    expect(page).to have_content 'My Organization'
  end

  it "user can click organizations quick link" do
    @p.click_quick_link("Organizations")

    expect(page).to have_content 'Organizations'
    expect(page).to have_content 'Important: Do NOT share this information'
  end

  it "user can click stats quick link" do
    @p.click_quick_link("Stats")

    expect(page).to have_content 'Stats by incident'
  end

  it "user can click graphs quick link" do
    @p.click_quick_link("Graphs")

    expect(page).to have_content 'Graphs'
    expect(page).to have_content 'Work Order Status'
  end
end
