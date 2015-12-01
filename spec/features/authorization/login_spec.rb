require 'rails_helper'

feature "Signing in" do

  scenario "Signing in as a worker with correct credentials" do
    sign_in_with_user
    expect(page).to have_content 'Worker Dashboard'
  end

  scenario "Signing in as an admin with correct credentials" do
    sign_in_with_admin
    expect(page).to have_content 'Admin Dashboard'
  end

  scenario "Signing in with incorrect credentials" do
    visit '/login'
    within("#new_user") do
      fill_in 'Email', :with => 'Gary@aol.com'
      fill_in 'Password', :with => 'incorrect'
    end
    click_button 'Log in'
    expect(page).to have_content 'Invalid email or password'
  end
end
