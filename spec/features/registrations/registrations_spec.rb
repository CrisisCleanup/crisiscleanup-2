require 'rails_helper'

describe "Going to the signup page page", :type => :feature, :js => true do
  it "has a New Organization Link" do
    visit '/signup'
    click_link 'Register Here'
    expect(page).to have_content 'Organization Sign Up'
  end
end

describe "Going to the signup page page", :type => :feature, :js => true do
  it "has a Just Curious Link" do
    visit '/signup'
    click_link 'Learn More'
    expect(page).to have_content 'The People and Philosophies of Crisis Cleanup'
  end
end

