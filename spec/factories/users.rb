FactoryGirl.define do
    factory :user do
      name "Gary"
      email Faker::Internet.email
      password "blue32blue32"
      accepted_terms true
      admin false
      legacy_organization_id 1
      is_disabled false
    end

    factory :admin, class: User do
      name "Frank"
      email Faker::Internet.email
      password "blue32blue32"
      accepted_terms true
      admin true
      legacy_organization_id 1
      is_disabled false
    end
end
