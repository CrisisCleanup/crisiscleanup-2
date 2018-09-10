SELECT legacy_events.id, legacy_events.name, legacy_events.start_date, COUNT(DISTINCT(legacy_organization_events.legacy_organization_id)) AS orgs, COUNT(DISTINCT(legacy_sites.id))
FROM legacy_events
LEFT JOIN legacy_organization_events ON legacy_events.id = legacy_organization_events.legacy_event_id
LEFT JOIN legacy_sites ON legacy_events.id = legacy_sites.legacy_event_id
GROUP BY legacy_events.id
ORDER BY legacy_events.id DESC;