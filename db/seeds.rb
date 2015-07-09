# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
5.times do 
	legacy_event = Legacy::LegacyEvent.create(
		case_label: Faker::Lorem.sentence,                                                                   
		name: Faker::Name.name,   
		short_name: Faker::Name.name,  
		created_date:  DateTime.now.to_date,                                   
		start_date: DateTime.now.to_date, 
		end_date: DateTime.now.to_date, 
		reminder_contents: Faker::Lorem.sentence,                                                 	                                     
		reminder_days: 12  
		)


	5.times do
		Legacy::LegacyOrganization.create(
			activate_by: DateTime.now.to_date,
			activated_at: DateTime.now.to_date,
			activation_code: Faker::Code.ean,
			address: Faker::Address.street_address,
			admin_notes: Faker::Lorem.sentence,
			city: Faker::Address.city,
			email: Faker::Internet.email,
			facebook: Faker::Internet.url('facebook.com'),
			is_active: true,
			latitude: Faker::Address.latitude,
			longitude: Faker::Address.longitude,
			name:   Faker::Name.name,
			password:  Faker::Internet.password,
			permissions: Faker::Lorem.word,
			phone: Faker::PhoneNumber.cell_phone,
			physical_presence:true,
			publish:true,
			reputable:true,
			state: Faker::Address.state,
			terms_privacy:Faker::Lorem.sentence,
			timestamp_login:DateTime.now,
			timestamp_signup:DateTime.now,
			twitter:Faker::Internet.url('twitter.com'),
			url:Faker::Internet.url('example.com'),
			work_area:Faker::Lorem.sentence,
			zip_code: Faker::Address.zip
		)
	end

	5.times do 
		Legacy::LegacySite.create(
			address: Faker::Address.street_address,                                     
			latitude:  Faker::Address.latitude,                                  
			longitude: Faker::Address.longitude,
			blurred_latitude:  Faker::Address.latitude,
			blurred_longitude: Faker::Address.longitude, 
			case_number: Faker::Lorem.sentence,
			city: Faker::Address.city,
			legacy_event_id: legacy_event.id,
			name:      Faker::Name.name,
			phone:       Faker::PhoneNumber.cell_phone,
			reported_by: 1,
			requested_at: DateTime.now.to_date,
			state:     Faker::Address.state,
			status: Faker::Lorem.sentence,
			work_type: Faker::Lorem.sentence

	) 
	end
end

