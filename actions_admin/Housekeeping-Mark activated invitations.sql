SELECT COUNT(DISTINCT(invitee_email)) AS unactivated_invitations
FROM invitations
WHERE activated = FALSE;

UPDATE invitations
SET activated = TRUE
WHERE invitee_email IN (
	SELECT email
	FROM users
);

SELECT COUNT(DISTINCT(invitee_email)) AS unactivated_invitations
FROM invitations
WHERE activated = FALSE;