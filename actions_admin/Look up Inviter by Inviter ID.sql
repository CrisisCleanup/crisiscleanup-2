SELECT invitations.user_id, invitations.invitee_email, users.name AS name, legacy_organizations.name AS org, legacy_organizations.id AS org_id, users.mobile AS phone, users.email AS email, users.encrypted_password AS pw 
FROM invitations 
LEFT JOIN users ON users.email=invitations.invitee_email 
LEFT JOIN legacy_organizations ON invitations.organization_id = legacy_organizations.id 
WHERE invitations.user_id='';