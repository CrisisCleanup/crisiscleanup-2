SET target.event_id = '37';
SET inviter.email = 'aaron@crisiscleanup.org';
SELECT users.id AS id, users.name AS name, legacy_organizations.name AS org, legacy_organizations.id AS org_id, users.mobile AS phone, users.email AS email, users.encrypted_password AS pw, users.created_at, users.last_sign_in_at
FROM users 
LEFT JOIN legacy_organizations ON users.legacy_organization_id = legacy_organizations.id
WHERE users.referring_user_id IN
	(SELECT users.id
	FROM users
	WHERE users.email = CAST(current_setting('inviter.email') AS text))
AND users.legacy_organization_id IN 
	(SELECT legacy_organization_events.legacy_organization_id
	FROM legacy_organization_events
	WHERE legacy_organization_events.legacy_event_id = CAST(current_setting('target.event_id') AS integer));