SET inviter.email = '';
UPDATE invitations
SET organization_id = 
	(SELECT legacy_organization_id
	FROM users
	WHERE email = current_setting('inviter.email')
	)
WHERE user_id = 
	(SELECT id
	FROM users
	WHERE email = current_setting('inviter.email')
	)
;