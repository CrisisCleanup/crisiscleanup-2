SET target.event_id = '';
SET start.case_number = '';
SELECT legacy_sites.id, legacy_events.name, legacy_sites.case_number, legacy_sites.city, legacy_sites.county, legacy_sites.state, legacy_sites.zip_code, legacy_sites.phone1, legacy_sites.phone2
FROM legacy_sites
LEFT JOIN legacy_events ON legacy_sites.legacy_event_id = legacy_events.id
WHERE legacy_sites.legacy_event_id = CAST(current_setting('target.event_id') AS integer)
AND legacy_sites.id > 
	(SELECT id
	FROM legacy_sites
	WHERE case_number = current_setting('start.case_number')
	AND legacy_event_id = CAST(current_setting('target.event_id') AS integer))
ORDER BY legacy_sites.id;