require 'rails_helper'

feature "Inviting a new user" do

  scenario "Regular user invites a user" do
    email = "NewUser@aol.com"
    sign_in_with_user
    send_invites(email)
    expect(page).to have_content "Invitation sent to #{email}"
  end

  scenario "Regular user invites multiple users" do
    emails = "NewUser11@aol.com, NewUser12@aol.com"
    sign_in_with_user
    send_invites(emails)
    expect(page).to have_content "Invitation sent to NewUser11@aol.com,NewUser12@aol.com"
  end

  scenario "User registers at emailed invite link and can navigate the system" do
    email = "NewUser3@aol.com"
    password = "password1"
    sign_in_with_user
    send_invites(email)
    invite_code = Invitation.last.token

    visit "/invitations/activate?token=#{invite_code}"
    within("#new_user") do
      fill_in 'Name', :with => 'New User Name'
      fill_in 'user_password', :with => password
      fill_in 'user_password_confirmation', :with => password
      check 'user_accepted_terms'
      click_button "Sign up"
    end
    expect(page).to have_content 'Worker Dashboard'
  end
end
