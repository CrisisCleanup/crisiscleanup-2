SELECT id, name, created_at FROM legacy_organizations
WHERE LOWER(name) LIKE LOWER('%***%')