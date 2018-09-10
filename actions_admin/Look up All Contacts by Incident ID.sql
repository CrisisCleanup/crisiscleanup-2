SELECT  legacy_organizations.name, legacy_contacts.first_name, legacy_contacts.last_name, legacy_contacts.email, legacy_contacts.phone 
FROM legacy_contacts
LEFT JOIN legacy_organizations ON legacy_contacts.legacy_organization_id = legacy_organizations.id
LEFT JOIN legacy_organization_events ON legacy_organization_events.legacy_organization_id = legacy_contacts.legacy_organization_id
WHERE legacy_organization_events.legacy_event_id = ***
ORDER BY legacy_organizations.name;