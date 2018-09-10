SET old.event_id = '';
SET new.event_id = '';
SET old.case_num = '';
SET new.case_label = '';
DISCARD TEMP;
CREATE TEMPORARY TABLE temp_data as
(
	SELECT legacy_sites.id FROM legacy_sites WHERE case_number = current_setting('old.case_num') AND legacy_event_id = CAST(current_setting('old.event_id') AS integer)
);
UPDATE legacy_sites SET legacy_event_id = CAST(current_setting('new.event_id') AS integer), case_number = current_setting('new.case_label')||subquery.next_case_number FROM (SELECT MAX(CAST(nullif(substring(case_number from 2 for char_length(case_number)), '') AS integer))+1 AS next_case_number FROM legacy_sites WHERE legacy_event_id = CAST(current_setting('new.event_id') AS integer)) AS subquery WHERE case_number = current_setting('old.case_num') AND legacy_event_id = CAST(current_setting('old.event_id') AS integer);
SELECT legacy_event_id, case_number, name, address FROM legacy_sites WHERE id = (SELECT id FROM temp_data);