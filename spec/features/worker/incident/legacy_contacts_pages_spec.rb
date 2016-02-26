require 'rails_helper'

describe "View worker contacts", :type => :feature, :js => true do
  it "loads a page with the proper main header" do
  	sign_in_with_user
    visit '/dashboard'
    find('.has-dropdown').hover
    click_link "Contacts"
    expect(page).to have_content 'All Organizations'
    expect(page).to have_content 'My Organization'
  end
end

describe "View individual worker contact", :type => :feature, :js => true do
  it "loads a page with the proper main header" do
  	@contact = FactoryGirl.create(:legacy_contact)

  	sign_in_with_user
    visit '/dashboard'
    find('.has-dropdown').hover
    click_link "Contacts"
    click_link "#{@contact.first_name}"
    expect(page).to have_content "#{@contact.first_name}"
    expect(page).to have_content "#{@contact.email}"
  end
end
