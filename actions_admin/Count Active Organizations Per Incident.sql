SELECT COUNT(DISTINCT(legacy_organization_id))
FROM legacy_organization_events
WHERE legacy_organization_id IN (
	SELECT DISTINCT(reported_by) FROM legacy_sites
	UNION
	SELECT DISTINCT(claimed_by) FROM legacy_sites)
AND legacy_event_id = ***;