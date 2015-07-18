FactoryGirl.define do
    factory :user do
      name "Gary"
      email "gary@aol.com"
      password "blue32blue32"
      admin false
      legacy_organization_id 1
    end

    factory :admin, class: User do
      name "Frank"
      email "frank@aol.com"
      password "blue32blue32"
      admin false
      legacy_organization_id 1
    end
end
