SELECT COUNT(DISTINCT(legacy_organization_id))
FROM legacy_organization_events
WHERE legacy_organization_id IN (
	SELECT id FROM legacy_organizations WHERE name NOT LIKE 'Local Admin%' AND is_active = 't')
AND legacy_event_id = ***;