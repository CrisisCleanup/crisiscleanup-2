SELECT id, name, activated_at, address, city, state, zip_code, email, phone, voad_referral, where_are_you_working, 
	work_area, url, facebook, not_an_org, does_damage_assessment, does_cleanup, does_follow_up, 
	does_rebuilding, does_coordination, does_only_coordination, does_only_sit_aware, does_something_else, 
	does_other_activity, government
	FROM legacy_organizations
WHERE org_verified = 't'
AND id IN (
	SELECT legacy_organization_id
	FROM legacy_organization_events
	WHERE legacy_event_id = 60
)
ORDER BY name;