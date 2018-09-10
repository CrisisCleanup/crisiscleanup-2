SELECT legacy_events.name as Event,
	legacy_sites.case_number AS Case_Number,
	legacy_sites.name AS Name,
	legacy_sites.address AS Address,
	legacy_sites.city AS City,
	legacy_sites.county AS County,
	legacy_sites.state AS State,
	legacy_sites.zip_code AS Zip,
	legacy_sites.phone1 AS Phone_1,
	legacy_sites.phone2 AS Phone_2,
	legacy_sites.latitude AS Latitude,
	legacy_sites.longitude AS Longitude,
	legacy_sites.blurred_latitude AS Blurred_Lat,
	legacy_sites.blurred_longitude AS Blurred_Lng,
	legacy_sites.reported_by AS Reported_By,
	legacy_organizations.name AS Claimed_By,
	legacy_sites.request_date AS Requested_Date,
	legacy_sites.updated_at AS Last_Updated,
	legacy_sites.status AS Status,
	legacy_sites.work_type AS Work_Type,
	legacy_sites.work_requested AS Work_Requested,
	legacy_sites.data -> 'floors_affected' AS Floors_Affected,
	legacy_sites.data -> 'flood_height' AS Flood_Height,
	legacy_sites.data -> 'flood_height_select' AS Flood_Height_Select,
	legacy_sites.data -> 'mold_amount' AS Amount_of_Mold,
	legacy_sites.data -> 'num_trees_down' AS Trees_Down,
	legacy_sites.data -> 'hours_worked_per_volunteer' AS Hours_Worked_Per_Volunteer,
	legacy_sites.data -> 'initials_of_resident_present' AS Initials_Of_Resident_Present,
	legacy_sites.data -> 'total_volunteers' AS Total_Volunteers,
	legacy_sites.data -> 'status_notes' AS Status_Notes,
	legacy_sites.data -> 'residence_type' AS Residence_Type,
	legacy_sites.data -> 'older_than_60' AS Older_Than_60,
	legacy_sites.data -> 'first_responder' AS First_Responder
FROM legacy_sites
LEFT JOIN legacy_events
	ON legacy_events.id = legacy_sites.legacy_event_id
LEFT JOIN legacy_organizations
	ON legacy_organizations.id = legacy_sites.claimed_by
WHERE legacy_sites.legacy_event_id = ***
ORDER BY legacy_sites.id;