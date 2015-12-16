FactoryGirl.define do
  factory :legacy_event, :class => Legacy::LegacyEvent do
    case_label Faker::Name.name
    name Faker::Name.name
    short_name Faker::Name.name
    created_date  DateTime.now.to_date
    start_date DateTime.now.to_date
    end_date DateTime.now.to_date
    reminder_contents Faker::Lorem.sentence
    reminder_days 12
  end
end
