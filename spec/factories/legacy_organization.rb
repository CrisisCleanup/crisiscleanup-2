FactoryGirl.define do
  factory :legacy_organization, :class => Legacy::LegacyOrganization do
	activate_by DateTime.now.to_date                                 
	activated_at DateTime.now.to_date                               
	activation_code Faker::Code.ean                         
	address Faker::Address.street_address                                     
	admin_notes Faker::Lorem.sentence

	city Faker::Address.city                                                 
	email Faker::Internet.email                                      
	facebook Faker::Internet.url('facebook.com')
	is_active true                                  
	is_admin  false                                 
	latitude  Faker::Address.latitude                                  
	longitude Faker::Address.longitude                                  
	name      Faker::Name.name                                                 
	password  Faker::Internet.password                                  
	permissions Faker::Lorem.word                                
	phone       Faker::PhoneNumber.cell_phone                                
	physical_presence true                          
	publish true                                     
	reputable true                                
	state     Faker::Address.state                                  
	terms_privacy Faker::Lorem.sentence
	timestamp_login DateTime.now
	timestamp_signup DateTime.now                           
	twitter Faker::Internet.url('twitter.com')
	url Faker::Internet.url('example.com')
	work_area Faker::Lorem.sentence                                 
	zip_code  Faker::Address.zip                                   	
  end
end  

