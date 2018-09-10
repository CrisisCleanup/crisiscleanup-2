SET thisthing.event_id = '';
SET thisthing.case_num = '';
SET thisthing.case_label = '';
SET new.claimed_by = '';
SET new.work_type = 'Mold_Remediation';
INSERT INTO legacy_sites (
  address, blurred_latitude, blurred_longitude, case_number, city, claimed_by, legacy_event_id, latitude, longitude, name, phone1, reported_by, requested_at, state, status, work_type, data, created_at, updated_at, request_date, appengine_key, zip_code, county, phone2, work_requested, name_metaphone, city_metaphone, county_metaphone, address_metaphone, user_id
)
SELECT address, blurred_latitude, blurred_longitude, case_number, city, CAST(current_setting('new.claimed_by') AS integer), legacy_event_id, latitude, longitude, name, phone1, reported_by, requested_at, state, 'Open, unassigned', CAST(current_setting('new.work_type') AS text), data, created_at, updated_at, request_date, appengine_key, zip_code, county, phone2, work_requested, name_metaphone, city_metaphone, county_metaphone, address_metaphone, user_id
FROM legacy_sites
WHERE case_number = current_setting('thisthing.case_num') AND legacy_event_id = CAST(current_setting('thisthing.event_id') AS integer);

UPDATE legacy_sites SET case_number = current_setting('thisthing.case_label')||subquery.next_case_number FROM (SELECT MAX(CAST(nullif(substring(case_number from 2 for char_length(case_number)), '') AS integer))+1 AS next_case_number FROM legacy_sites WHERE legacy_event_id = CAST(current_setting('thisthing.event_id') AS integer)) AS subquery
WHERE id = (SELECT id FROM legacy_sites WHERE case_number = current_setting('thisthing.case_num') AND legacy_event_id = CAST(current_setting('thisthing.event_id') AS integer) ORDER BY id DESC LIMIT 1 OFFSET 0);

SELECT current_setting('thisthing.case_label')||MAX(CAST(nullif(substring(case_number from 2 for char_length(case_number)), '') AS integer)) AS next_case_number FROM legacy_sites WHERE legacy_event_id = CAST(current_setting('thisthing.event_id') AS integer);
