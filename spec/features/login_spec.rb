require 'rails_helper'

feature "Signing in" do
  background do
    org = FactoryGirl.create(:legacy_organization)
    org_event = FactoryGirl.create(:legacy_organization_event, legacy_organization_id: org.id)
    FactoryGirl.create(:user, email: "Gary@aol.com", password: "blue32blue32", legacy_organization_id: org.id, verified: true)
    FactoryGirl.create(:admin, email: "Admin@aol.com", password: "blue32blue32", legacy_organization_id: org.id, verified: true)

  end

  scenario "Signing in as a worker with correct credentials" do
    visit '/login'
    within("#new_user") do
      fill_in 'Email', :with => 'Gary@aol.com'
      fill_in 'Password', :with => 'blue32blue32'
    end
    click_button 'Log in'
    expect(page).to have_content 'Worker Dashboard'
  end
  scenario "Signing in as a worker with incorrect credentials" do
    visit '/login'
    within("#new_user") do
      fill_in 'Email', :with => 'Gary@aol.com'
      fill_in 'Password', :with => 'incorrect'
    end
    click_button 'Log in'
    expect(page).to have_content 'Invalid email or password'
  end

  scenario "Signing in as an admin with correct credentials" do
    visit '/login'
    within("#new_user") do
      fill_in 'Email', :with => 'Admin@aol.com'
      fill_in 'Password', :with => 'blue32blue32'
    end
    click_button 'Log in'
    expect(page).to have_content 'Admin Dashboard'
  end
end
