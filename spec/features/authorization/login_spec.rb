require 'rails_helper'

describe "Signing in", :type => :feature, :js => true do

  # before do
    # require "#{Rails.root}/db/seeds.rb"
  # end
  # it "with base user" do
  #   sign_in_with("demo@crisiscleanup.org", "password")
  #   expect(page).to have_content 'My Work Dashboard'
  # end

  it "as a worker with correct credentials" do
    sign_in_with_user
    expect(page).to have_content 'My Work Dashboard'
  end

  it "as an admin with correct credentials" do
    sign_in_with_admin
    expect(page).to have_content 'Admin Dashboard'
  end

  it "with incorrect credentials" do
    visit '/login'
    within("#new_user") do
      fill_in 'Email', :with => 'Gary@aol.com'
      fill_in 'Password', :with => 'incorrect'
    end
    click_button 'Log in'
    expect(page).to have_content 'Invalid email or password'
  end
end
