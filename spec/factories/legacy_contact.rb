FactoryGirl.define do
  factory :legacy_contact, :class => Legacy::LegacyContact do
    first_name Faker::Name.name
    last_name Faker::Name.name
    email Faker::Name.name
    legacy_organization_id 1
    is_primary false
    phone "1234567890"
    appengine_key Faker::Lorem.sentence
  end

  factory :invalid_legacy_contact, :class => Legacy::LegacyContact do
    first_name
    last_name
    email
    legacy_organization_id
    is_primary
    phone
    appengine_key
  end
end
