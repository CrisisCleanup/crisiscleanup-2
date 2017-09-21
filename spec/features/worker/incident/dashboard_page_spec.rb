require 'rails_helper'

describe "View worker dashboard", :type => :feature, :js => true do
  it "loads a page with the proper main header" do
  	email = sign_in_with_user

    base_worker_page = Pages::BaseWorkerPage.new
    base_worker_page.click_dashboard_link

    expect(page).to have_content 'My Work Dashboard'
  end
end
