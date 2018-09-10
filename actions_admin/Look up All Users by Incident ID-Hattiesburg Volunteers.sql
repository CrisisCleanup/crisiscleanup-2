SELECT users.id AS id, users.name AS name, legacy_organizations.name AS org, users.mobile AS phone, users.email AS email, users.created_at, users.last_sign_in_at
FROM users 
LEFT JOIN legacy_organizations ON users.legacy_organization_id = legacy_organizations.id
WHERE legacy_organizations.id = 243 OR legacy_organizations.id = 981 OR legacy_organizations.id = 468 ORDER BY legacy_organizations.name, users.last_sign_in_at DESC;