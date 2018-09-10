SELECT DISTINCT(id), legacy_event_id, case_number, claimed_by, legacy_event_id, work_type, status, legacy_sites.data -> 'num_trees_down' AS num_trees, legacy_sites.data -> 'num_wide_trees' AS num_wide_trees
FROM legacy_sites
ORDER BY id;