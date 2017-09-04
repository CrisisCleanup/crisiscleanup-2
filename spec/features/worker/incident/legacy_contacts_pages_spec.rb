# require 'rails_helper'

describe "View worker contacts" do
  it "loads a page with the proper main header" do

    email = sign_in_with_user

    page = Pages::WorkerContactPage.new
    page.click_contacts_link

    expect(page).to have_content 'All Organizations'
    expect(page).to have_content 'My Organization'
  end
end

describe "View individual worker contact" do
  it "loads a page with the proper main header" do
  	@contact = FactoryGirl.create(:legacy_contact)

    email = sign_in_with_user

    page = Pages::WorkerContactPage.new
    page.click_contacts_link

    save_and_open_page

    # click_link "#{@contact.first_name}"
    expect(page).to have_content "#{@contact.first_name}"
    expect(page).to have_content "#{@contact.email}"
  end
end
