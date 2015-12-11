FactoryGirl.define do
  factory :legacy_organization_event, :class => Legacy::LegacyOrganizationEvent do
    legacy_organization_id 1
    legacy_event_id 1
  end
end

