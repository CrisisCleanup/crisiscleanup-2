# require 'rails_helper'

# describe "View worker contacts", :type => :feature, :js => true do
#   it "loads a page with the proper main header" do
#   	sign_in_with_user
#     visit '/dashboard'
#     find('.has-dropdown').hover
#     click_link "Orgs"
#     expect(page).to have_content 'Website'
#     expect(page).to have_content 'Primary Contact'
#   end
# end

# describe "View individual worker contact", :type => :feature, :js => true do
#   it "loads a page with the proper main header" do
#   	@organization = FactoryGirl.create(:legacy_organization, name: "Org test", email: "Orgtest@email.com")
#   	org_event = FactoryGirl.create(:legacy_organization_event, legacy_organization_id: @organization.id, legacy_event_id: 1)

#   	sign_in_with_user
#     visit '/dashboard'
#     find('.has-dropdown').hover
#     click_link "Orgs"
#     binding.pry
#     click_link "#{@organization.name}"
#     expect(page).to have_content "#{@organization.first_name}"
#     expect(page).to have_content "#{@organization.email}"
#   end
# end



