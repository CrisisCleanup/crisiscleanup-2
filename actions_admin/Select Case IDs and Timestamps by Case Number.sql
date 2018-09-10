SELECT legacy_sites.id, legacy_sites.case_number, legacy_sites.status, legacy_organizations.name AS claiming_org, legacy_sites.name, legacy_sites.legacy_event_id, legacy_sites.created_at, legacy_sites.updated_at, legacy_sites.requested_at, legacy_sites.request_date
FROM legacy_sites
LEFT JOIN legacy_organizations ON legacy_sites.claimed_by = legacy_organizations.id
WHERE case_number = 'P1034'
OR case_number = 'P1474'
OR case_number = 'P1501'
OR case_number = 'P1878'
OR case_number = 'P1940'
OR case_number = 'P1972'
OR case_number = 'P2924'
OR case_number = 'P3194'
AND legacy_event_id = '41'
ORDER BY id;