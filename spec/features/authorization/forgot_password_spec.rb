require 'rails_helper'

feature "Signing in" do
	background do
		org = FactoryGirl.create(:legacy_organization)
		org_event = FactoryGirl.create(:legacy_organization_event, legacy_organization_id: org.id)
		FactoryGirl.create(:user, email: "Gary@aol.com", password: "blue32blue32", legacy_organization_id: org.id)
	end

	scenario "User clicks 'Forgot your password'" do
	  visit '/login'
	  click_link('Forgot your password')
	  expect(page).to have_content 'Enter your email address below'
	end

	scenario "User enters correct password and clicks submit button" do
		visit '/password/new'
		within("#new_user") do
			fill_in 'Email', :with => 'Gary@aol.com'
			click_button "Send me reset password instructions"
		end
		expect(page).to have_content 'You will receive an email with instructions'
	end

	# scenario "User clicks reset password link" do
	# 	See here for more: https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
	# end

	scenario "User enters incorrect password and clicks submit button" do
		visit '/password/new'
		within("#new_user") do
			fill_in 'Email', :with => 'incorrect@email.com'
			click_button "Send me reset password instructions"
		end
		expect(page).to have_content 'not found'
	end
end