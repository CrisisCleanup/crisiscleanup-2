SELECT id AS event_id, name AS event_name FROM legacy_events
WHERE id IN (
	SELECT legacy_event_id FROM legacy_organization_events
	WHERE legacy_organization_id = ***)