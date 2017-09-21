require 'rails_helper'

describe "Signing in", :type => :feature, :js => true do
	before do
    org = FactoryGirl.create(:legacy_organization)
    event = FactoryGirl.create(:legacy_event)
    org.legacy_events << event
    email = "Gary@aol.com"
    FactoryGirl.create(:user, email: email, password: "blue32blue32", legacy_organization_id: org.id)
	end

	it "User clicks 'Forgot your password'" do
	  visit '/login'
	  click_link('Forgot your password')
	  expect(page).to have_content 'Enter your email address below'
	end

	it "User enters correct password and clicks submit button" do
		visit '/password/new'
		within("#new_user") do
			fill_in 'Email', :with => 'Gary@aol.com'
			click_button "Send me reset password instructions"
		end
		expect(page).to have_content 'You will receive an email with instructions'
	end

	it "User enters incorrect password and clicks submit button" do
		visit '/password/new'
		within("#new_user") do
			fill_in 'Email', :with => 'incorrect@email.com'
			click_button "Send me reset password instructions"
		end
		expect(page).to have_content 'not found'
	end
end