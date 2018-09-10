SELECT legacy_sites.id, legacy_sites.legacy_event_id, legacy_sites.case_number, legacy_sites.claimed_by, legacy_organizations.name AS org_name, legacy_sites.status, legacy_sites.name AS resident_name
FROM legacy_sites
LEFT JOIN legacy_organizations ON legacy_sites.claimed_by = legacy_organizations.id
WHERE legacy_sites.claimed_by IS NULL
AND legacy_sites.status <> 'Open, unassigned'
AND legacy_sites.legacy_event_id = ;