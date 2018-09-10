SELECT legacy_organizations.name, COUNT(legacy_organization_id) AS events
FROM legacy_organizations
LEFT JOIN legacy_organization_events ON legacy_organizations.id = legacy_organization_events.legacy_organization_id
GROUP BY legacy_organizations.name
ORDER BY legacy_organizations.name;