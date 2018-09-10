SET target.email = '';
SET target.action = 'create'; /* Set to either 'create' or 'update' */

SELECT DISTINCT(legacy_sites.case_number), legacy_events.name AS incident, versions.event AS action  FROM versions
LEFT JOIN legacy_sites ON versions.item_id = legacy_sites.id
LEFT JOIN legacy_events ON legacy_events.id = legacy_sites.legacy_event_id
WHERE versions.item_type = 'Legacy::LegacySite'
AND whodunnit = CAST((
	SELECT id
	FROM users
	WHERE email =CAST(current_setting('target.email') AS text)
) AS text)
AND versions.event = CAST(current_setting('target.action') AS text)
ORDER BY case_number;