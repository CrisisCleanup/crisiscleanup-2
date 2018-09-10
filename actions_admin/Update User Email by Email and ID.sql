SET old.user_email = '';
SET new.user_email = '';

UPDATE users
SET email = current_setting('new.user_email')
WHERE email = current_setting('old.user_email');

/* SELECT USER BY EMAIL */
SELECT users.id AS id, users.name AS name, legacy_organizations.name AS org, legacy_organizations.id AS org_id, users.mobile AS phone, users.email AS email, users.encrypted_password AS pw, users.created_at, users.last_sign_in_at
FROM users 
LEFT JOIN legacy_organizations ON users.legacy_organization_id = legacy_organizations.id
WHERE users.email = current_setting('new.user_email');