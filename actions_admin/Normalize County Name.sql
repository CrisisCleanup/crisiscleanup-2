SET old.county_name = '';
SET new.county_name = '';
SET target.state_name = '';
SET target.event_id = '';
UPDATE legacy_sites SET county = CAST(current_setting('new.county_name') AS text) WHERE county = CAST(current_setting('old.county_name') AS text) AND state = CAST(current_setting('target.state_name') AS text) AND legacy_event_id = CAST(current_setting('target.event_id') AS integer);