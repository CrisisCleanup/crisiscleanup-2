require 'rails_helper'

describe "View worker contacts", :type => :feature, :js => true do
  it "loads a page with the proper main header" do
  	sign_in_with_user
    visit '/dashboard'
    click_button 'Generate Password'
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content "Temporary password successfully created"
  end
end
