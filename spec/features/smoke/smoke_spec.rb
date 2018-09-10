require 'rails_helper'

feature "Smoke test", :js => true do

  scenario "test navigation" do
    sign_in_with_admin

    nav = Pages::BaseAdminPage.new

    nav.click_admin_link
    expect(page).to have_title "Crisis Cleanup - Admin dashboard"
  end

end
