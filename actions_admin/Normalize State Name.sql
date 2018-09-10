SET old.state_name = '';
SET new.state_name = '';
SET target.event_id = '';
UPDATE legacy_sites SET state = CAST(current_setting('new.state_name') AS text) WHERE state = CAST(current_setting('old.state_name') AS text) AND legacy_event_id = CAST(current_setting('target.event_id') AS integer);