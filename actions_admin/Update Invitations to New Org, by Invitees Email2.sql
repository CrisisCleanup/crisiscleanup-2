SET new.org_id = '';
SET target.email = '';
UPDATE invitations
SET organization_id = CAST(current_setting('new.org_id') AS integer)
WHERE user_id =
	(SELECT id
	FROM users
	WHERE email = current_setting('target.email')
	)
;