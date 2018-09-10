SELECT id, case_number, created_at, claimed_by, legacy_event_id, work_type, status
FROM legacy_sites
WHERE legacy_event_id = 41
ORDER BY created_at DESC;