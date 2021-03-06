﻿SELECT invitations.id AS invitee_id, invitations.invitee_email AS invitee_email, users.name AS inviter_name, users.email AS inviter_email, legacy_organizations.name AS org_name, invitations.token, invitations.expiration, invitations.activated FROM invitations
LEFT JOIN users ON users.id = invitations.user_id
LEFT JOIN legacy_organizations ON legacy_organizations.id = invitations.organization_id
WHERE invitations.activated = 'f'
AND invitations.expiration <= now()
ORDER BY invitee_email, invitations.expiration DESC;