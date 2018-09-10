SET target.event_id = '';
SET target.site_id ='';
SET target.case_label = '';
UPDATE legacy_sites
SET case_number = current_setting('target.case_label')||subquery.next_case_number
FROM
	(SELECT MAX(CAST(nullif(substring(case_number from 2 for char_length(case_number)), '') AS integer))+1 AS next_case_number 
	FROM legacy_sites
	WHERE legacy_event_id = CAST(current_setting('target.event_id') AS integer)) AS subquery 
WHERE id = CAST(current_setting('target.site_id') AS integer)
AND legacy_event_id = CAST(current_setting('target.event_id') AS integer);