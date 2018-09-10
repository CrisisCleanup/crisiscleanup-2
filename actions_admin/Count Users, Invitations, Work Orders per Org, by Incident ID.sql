-- These are common indicators of vitality and participation for organizations, but I just haven't figured out how to combine them, yet.

SELECT legacy_organizations.id, legacy_organizations.name AS org_name, COUNT(users.id) AS user_count
FROM legacy_organizations
LEFT JOIN users ON users.legacy_organization_id = legacy_organizations.id
WHERE legacy_organizations.id IN (
	SELECT legacy_organization_id
	FROM legacy_organization_events
	WHERE legacy_event_id ='52'
	)
GROUP BY legacy_organizations.id
ORDER BY legacy_organizations.name;


SELECT legacy_organizations.id, COUNT(DISTINCT(invitations.invitee_email)) AS invitation_count
FROM legacy_organizations
LEFT JOIN invitations ON invitations.organization_id = legacy_organizations.id
WHERE legacy_organizations.id IN (
	SELECT legacy_organization_id
	FROM legacy_organization_events
	WHERE legacy_event_id ='52'
	)
GROUP BY legacy_organizations.id
ORDER BY legacy_organizations.name;

SELECT legacy_organizations.id, COUNT(legacy_sites.claimed_by) AS claimed_count
FROM legacy_organizations
LEFT JOIN legacy_sites ON legacy_sites.claimed_by = legacy_organizations.id
WHERE legacy_organizations.id IN (
	SELECT legacy_organization_id
	FROM legacy_organization_events
	WHERE legacy_event_id ='52'
	)
AND legacy_sites.legacy_event_id ='52'
GROUP BY legacy_organizations.id
ORDER BY legacy_organizations.name;

SELECT legacy_organizations.id, COUNT(legacy_sites.reported_by) AS reported_count
FROM legacy_organizations
LEFT JOIN legacy_sites ON legacy_sites.reported_by = legacy_organizations.id
WHERE legacy_organizations.id IN (
	SELECT legacy_organization_id
	FROM legacy_organization_events
	WHERE legacy_event_id ='52'
	)
AND legacy_sites.legacy_event_id ='52'
GROUP BY legacy_organizations.id
ORDER BY legacy_organizations.name;