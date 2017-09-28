require 'rails_helper'

describe "Inviting a new user", :type => :feature, :js => true do

  it "Regular user invites a user" do
    email = "NewUser@aol.com"
    sign_in_with_user

    p = Pages::WorkerDashboardPage.new
    p.send_invites(email)

    if page.driver == :selenium
      accept_alert do
        text = page.driver.browser.switch_to.alert.text
        expect(text).to eq 'Please confirm that you would like to invite these people to your organization.'
      end
    end

    # Change is here:
    expect(page).to have_content "Invitation sent to #{email}"
  end

  it "Regular user invites multiple users" do
    emails = "NewUser11@aol.com, NewUser12@aol.com"
    sign_in_with_user

    p = Pages::WorkerDashboardPage.new
    p.send_invites(emails)

    if page.driver == :selenium
      accept_alert do
        text = page.driver.browser.switch_to.alert.text
        expect(text).to eq 'Please confirm that you would like to invite these people to your organization.'
      end
    end

    expect(page).to have_content "Invitation sent to NewUser11@aol.com,NewUser12@aol.com"
  end


  # it "User registers at emailed invite link and can navigate the system" do
  #   email = "NewUser3@aol.com"
  #   password = "password1"
  #   sign_in_with_user
  #   send_invites(email)
  #   accept_alert do
  #     text = page.driver.browser.switch_to.alert.text
  #     expect(text).to eq 'Please confirm that you would like to invite these people to your organization.'
  #   end
  #   invite_code = Invitation.last.token
  #
  #   visit "/invitations/activate?token=#{invite_code}"
  #   within("#new_user") do
  #     fill_in 'Name', :with => 'New User Name'
  #     fill_in 'user_password', :with => password
  #     fill_in 'user_password_confirmation', :with => password
  #     check 'user_accepted_terms'
  #     click_button "Sign up"
  #   end
  #   expect(page).to have_content 'My Work Dashboard'
  # end
end
