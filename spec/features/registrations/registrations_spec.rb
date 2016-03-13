require 'rails_helper'

describe "Going to the signup page page", :type => :feature do
  it "has a New Organization Link" do
    visit '/signup'
    click_link 'New Organization'
    expect(page).to have_content 'Sign Up For Crisis Cleanup'
  end
end

describe "Going to the signup page page", :type => :feature do
  it "has a New Organization Link" do
    visit '/signup'
    click_link 'I Have a Temporary Password'
    expect(page).to have_content 'Use a temporary password'
  end
end

describe "Going to the signup page page", :type => :feature do
  it "has a New Organization Link" do
    visit '/signup'
    click_link 'New Incident'
    expect(page).to have_content 'Request to use CrisisCleanup for a new incident.'
  end
end

describe "Going to the signup page page", :type => :feature do
  it "has a New Organization Link" do
    visit '/signup'
    click_link 'Redeploy Your Organization'
    expect(page).to have_content 'Redeploy to a new incident.'
  end
end

describe "Going to the signup page page", :type => :feature do
  it "has a New Organization Link" do
    visit '/signup'
    click_link 'Just Curious'
    expect(page).to have_content 'The People and Philosophies of Crisis Cleanup'
  end
end

