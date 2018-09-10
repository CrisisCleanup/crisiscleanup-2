SELECT users.id AS id, users.name AS name, legacy_organizations.name AS org, legacy_organizations.id AS org_id, users.mobile AS phone, users.email AS email, users.encrypted_password AS pw, users.created_at, users.last_sign_in_at
FROM users 
LEFT JOIN legacy_organizations ON users.legacy_organization_id = legacy_organizations.id
WHERE users.name LIKE '%%';