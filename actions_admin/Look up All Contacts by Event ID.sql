SELECT legacy_contacts.id AS id, legacy_contacts.first_name AS first_name, legacy_contacts.last_name, legacy_contacts.email AS email, legacy_organizations.name AS org, legacy_contacts.is_primary AS primary, legacy_organizations.id AS org_id, legacy_contacts.phone AS phone
FROM legacy_contacts
LEFT JOIN legacy_organizations ON legacy_contacts.legacy_organization_id = legacy_organizations.id
LEFT JOIN legacy_organization_events ON legacy_organizations.id = legacy_organization_events.legacy_organization_id
WHERE legacy_organization_events.legacy_event_id = ***
ORDER BY legacy_organizations.name, legacy_contacts.last_name;