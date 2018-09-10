SET target.user_email = '';
SET new.expiration = '2017-07-31 01:00:00';

UPDATE invitations
SET expiration = to_timestamp(current_setting('new.expiration'), 'YYYY-MM-DD HH24:MI:SS')
WHERE invitee_email = current_setting('target.user_email');

SELECT invitations.id AS invitee_id, invitations.invitee_email AS invitee_email, users.name AS inviter_name, users.email AS inviter_email, legacy_organizations.name AS org_name, invitations.token, invitations.expiration, invitations.activated FROM invitations
LEFT JOIN users ON users.id = invitations.user_id
LEFT JOIN legacy_organizations ON legacy_organizations.id = invitations.organization_id
WHERE invitations.invitee_email = current_setting('target.user_email');