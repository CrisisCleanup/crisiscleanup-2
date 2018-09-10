SET target.event_id = '';
SELECT legacy_organizations.id, legacy_organizations.name, legacy_organizations.created_at, COUNT(users.id) AS users
FROM legacy_organizations
LEFT JOIN users
ON legacy_organizations.id = users.legacy_organization_id
WHERE legacy_organizations.id IN (
	SELECT legacy_organization_id
	FROM legacy_organization_events
	WHERE legacy_event_id = CAST(current_setting('target.event_id') AS integer))
AND is_active = 't'
GROUP BY legacy_organizations.id
ORDER BY legacy_organizations.name;