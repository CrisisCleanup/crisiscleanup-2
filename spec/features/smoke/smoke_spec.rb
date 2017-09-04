require 'rails_helper'

feature "Smoke test" do

  scenario "public maps" do
    visit '/public_map'
    maps_page = Pages::Maps.new

    create_incident

    maps_page.select_incident(1)
  end

  scenario "test navigation" do
    sign_in_with_admin

    nav = Pages::BaseAdminPage.new

    nav.click_admin_link
    expect(page).to have_title "Crisis Cleanup - Admin dashboard"
  end

end
