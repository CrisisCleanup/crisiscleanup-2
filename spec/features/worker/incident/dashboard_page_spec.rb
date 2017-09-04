require 'rails_helper'

describe "View worker dashboard" do
  it "loads a page with the proper main header" do
  	email = sign_in_with_user

    base_worker_page = Pages::BaseWorkerPage.new
    base_worker_page.click_dashboard_link

    expect(page).to have_content 'Worker Dashboard'
    expect(page).to have_content email.downcase
  end
end
