module Features
  module SessionHelpers
  	def sign_in_with_admin
      org = FactoryGirl.create(:legacy_organization)
	  org_event = FactoryGirl.create(:legacy_organization_event, legacy_organization_id: org.id)
	  FactoryGirl.create(:admin, email: "Admin@aol.com", password: "blue32blue32", legacy_organization_id: org.id)

      visit "/login"
      fill_in 'Email', with: "Admin@aol.com"
      fill_in 'Password', with: "blue32blue32"
      click_button 'Log in'
  	end

    def sign_in_with_user
      org = FactoryGirl.create(:legacy_organization)
      event = FactoryGirl.create(:legacy_event)
      org_event = FactoryGirl.create(:legacy_organization_event, legacy_organization_id: org.id, legacy_event_id: 1)
	    FactoryGirl.create(:user, email: "Gary@aol.com", password: "blue32blue32", legacy_organization_id: org.id)

      visit "/login"
      fill_in 'Email', with: "Gary@aol.com"
      fill_in 'Password', with: "blue32blue32"
      click_button 'Log in'
    end

    def sign_in_with(email, password)
      visit "/login"
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Log in'
    end

    def send_invites(email_addresses)
    	fill_in 'email_addresses', with: email_addresses
    	click_button 'Submit Invites'
    end
  end
end