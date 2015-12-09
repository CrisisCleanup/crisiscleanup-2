FactoryGirl.define do
  factory :request_invitation, :class => RequestInvitation do                         
	name Faker::Name.name
	email Faker::Internet.email
	user_created false 
	invited false       
	legacy_organization_id 1                                                        	
  end
end  

