FactoryGirl.define do
  lat = Faker::Address.latitude
  lng = Faker::Address.longitude

  factory :legacy_site, :class => Legacy::LegacySite do
    address Faker::Address.street_address
    latitude lat
    longitude lng
    blurred_latitude lat #+ rand(-0.0187..0.0187)
    blurred_longitude lng #+ rand(-0.0187..0.0187)
    case_number Faker::Code.isbn
    city Faker::Address.city
    county Faker::Lorem.word
    legacy_event_id 1
    name Faker::Name.name
    phone1 Faker::PhoneNumber.cell_phone
    reported_by 1
    request_date DateTime.now.to_date
    state Faker::Address.state
    zip_code Faker::Address.zip_code
    data {{
        email: Faker::Internet.email
    }}
    status [
      "Open, unassigned",
      # "Open, assigned",
      # "Open, partially completed",
      # "Open, needs follow-up",
      # "Closed, completed",
      # "Closed, incompleted",
      # "Closed, out of scope",
      # "Closed, done by others",
      # "Closed, no help wanted",
      # "Closed, rejected",
      # "Closed, duplicate"
    ].sample
    work_type ["Muck Out","Trees","Tarp","Debris","Mold Remediation","Rebuild","Other"].sample
  end
end

