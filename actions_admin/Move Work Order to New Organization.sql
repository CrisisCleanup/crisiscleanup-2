SET new.org_id = '';
SET target.event_id = '';
SET target.case_number = '';
UPDATE legacy_sites
SET claimed_by = CAST(current_setting('new.org_id') AS integer)
WHERE legacy_event_id = CAST(current_setting('target.event_id') AS integer)
AND case_number = current_setting('target.case_number');