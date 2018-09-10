SET vol.lds = '500';
SET vol.ldscharities = '1';
SET vol.ldsward = '-475';
SET vol.org = '25';

SELECT(
	SELECT COUNT(legacy_organizations.id)*CAST(current_setting('vol.lds') AS integer) 
	AS lds_volunteers 
FROM legacy_organization_events 
LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id 
WHERE legacy_organizations.name LIKE 'LDS Church%')+
(SELECT(
	SELECT COUNT(legacy_organizations.id)*CAST(current_setting('vol.ldsward') AS integer) 
	AS lds_ward_volunteers 
FROM legacy_organization_events 
LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id 
WHERE legacy_organizations.name LIKE 'LDS Charities%'))+
(SELECT(
	SELECT COUNT(legacy_organizations.id)*CAST(current_setting('vol.ldscharities') AS integer) 
	AS lds_charities_volunteers 
FROM legacy_organization_events 
LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id 
WHERE legacy_organizations.name LIKE '%Ward%')) AS volunteer_count