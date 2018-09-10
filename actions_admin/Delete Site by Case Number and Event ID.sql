SET the.event_id = '';
SET the.case_num = '';
DELETE FROM legacy_sites WHERE legacy_event_id = CAST(current_setting('the.event_id') AS integer) AND case_number = current_setting('the.case_num');