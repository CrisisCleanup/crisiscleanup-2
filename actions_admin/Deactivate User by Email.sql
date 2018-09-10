SET old.email_prefix = '';
SET old.email_domain = '';

UPDATE users
SET email = CAST(current_setting('old.email_prefix') AS text)||'x@'||CAST(current_setting('old.email_domain') AS text), encrypted_password = 'DELETED'
WHERE email = CAST(current_setting('old.email_prefix') AS text)||'@'||CAST(current_setting('old.email_domain') AS text);

SELECT users.id AS id, users.name AS name, legacy_organizations.name AS org, legacy_organizations.id AS org_id, users.mobile AS phone, users.email AS email, users.encrypted_password AS pw, users.created_at, users.last_sign_in_at
FROM users 
LEFT JOIN legacy_organizations ON users.legacy_organization_id = legacy_organizations.id
WHERE users.email = CAST(current_setting('old.email_prefix') AS text)||'x@'||CAST(current_setting('old.email_domain') AS text);