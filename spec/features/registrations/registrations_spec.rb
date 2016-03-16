require 'rails_helper'

describe "Going to the signup page page", :type => :feature do
  it "has a New Organization Link" do
    visit '/signup'
    click_link 'Register Here'
    expect(page).to have_content 'Organization Sign Up'
  end
end

describe "Going to the signup page page", :type => :feature do
  it "has a New Organization Link" do
    visit '/signup'
    click_link 'Use Password'
    expect(page).to have_content 'Use a temporary password'
  end
end

describe "Going to the signup page page", :type => :feature do
  it "has a New Organization Link" do
    visit '/signup'
    click_link 'Register Now'
    expect(page).to have_content 'Request to use CrisisCleanup for a new incident.'
  end
end

describe "Going to the signup page page", :type => :feature do
  it "has a New Organization Link" do
    visit '/signup'
    click_link 'Redeploy Now'
    expect(page).to have_content 'Redeploy to a new incident.'
  end
end

describe "Going to the signup page page", :type => :feature do
  it "has a New Organization Link" do
    visit '/signup'
    click_link 'Learn More'
    expect(page).to have_content 'The People and Philosophies of Crisis Cleanup'
  end
end

