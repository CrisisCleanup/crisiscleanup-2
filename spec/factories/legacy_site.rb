FactoryGirl.define do
  factory :legacy_site, :class => Legacy::LegacySite do
    address Faker::Address.street_address
    latitude Faker::Address.latitude
    longitude Faker::Address.longitude
    blurred_latitude Faker::Address.latitude
    blurred_longitude Faker::Address.longitude
    case_number Faker::Code.isbn
    city Faker::Address.city
    legacy_event_id 1
    name Faker::Name.name
    phone Faker::PhoneNumber.cell_phone
    reported_by 1
    request_date DateTime.now.to_date
    state Faker::Address.state
    status [
      "Open, unassigned",
      "Open, assigned",
      "Open, partially completed",
      "Open, needs follow-up",
      "Closed, completed",
      "Closed, incompleted",
      "Closed, out of scope",
      "Closed, done by others",
      "Closed, no help wanted",
      "Closed, rejected",
      "Closed, duplicate"
    ].sample
    work_type ["Flood","Debris Removal","Trees","Tornado","Tarp","Damage Report","Other"].sample
  end
end

