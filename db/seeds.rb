# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
20.times do 
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
	10.times do 
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

