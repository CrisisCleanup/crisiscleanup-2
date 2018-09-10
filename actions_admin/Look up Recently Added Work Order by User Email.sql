SET target.email = '***';
SET number.recents = 10;

SELECT legacy_sites.case_number, legacy_sites.name, legacy_sites.address, legacy_sites.city, legacy_sites.state
FROM versions
LEFT JOIN legacy_sites
ON legacy_sites.id = versions.item_id
WHERE whodunnit = (
    SELECT CAST(id AS text)
    FROM users
    WHERE email = CAST(current_setting('target.email')
	AS text))
ORDER BY versions.created_at DESC
LIMIT CAST(current_setting('number.recents') AS integer);