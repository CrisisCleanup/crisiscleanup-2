/*Common Scripts*/
/*C:\Users\Aaron\Documents\My Dropbox\Crisis Cleanup\Incidents\Example SQL*/


/* CALCULATE VALUE OF SERVICES */
SELECT id, case_number, claimed_by, legacy_event_id, work_type, status, legacy_sites.data -> 'num_trees_down' AS num_trees, legacy_sites.data -> 'num_wide_trees' AS num_wide_trees
FROM legacy_sites
ORDER BY id;

/* HOUSEKEEPING MARK ACTIVATED INVITATIONS */
SELECT COUNT(DISTINCT(invitee_email)) AS unactivated_invitations
FROM invitations
WHERE activated = FALSE;

UPDATE invitations
SET activated = TRUE
WHERE invitee_email IN (
	SELECT email
	FROM users
);

SELECT COUNT(DISTINCT(invitee_email)) AS unactivated_invitations
FROM invitations
WHERE activated = FALSE;

/* LOOK UP USER BY EMAIL */
SELECT users.id AS id, users.name AS name, legacy_organizations.name AS org, legacy_organizations.id AS org_id, users.mobile AS phone, users.email AS email, users.encrypted_password AS pw, users.created_at, users.last_sign_in_at
FROM users 
LEFT JOIN legacy_organizations ON users.legacy_organization_id = legacy_organizations.id
WHERE users.email='maria.delacruz@houstontx.gov';

/* LOOK UP INVITEE BY INVITEE EMAIL */
SELECT invitations.id AS invitee_id, invitations.invitee_email AS invitee_email, users.name AS inviter_name, users.email AS inviter_email, legacy_organizations.name AS org_name, 'https://www.crisiscleanup.org/invitations/activate?token='||invitations.token AS activation_link, invitations.expiration, invitations.activated FROM invitations
LEFT JOIN users ON users.id = invitations.user_id
LEFT JOIN legacy_organizations ON legacy_organizations.id = invitations.organization_id
WHERE invitations.invitee_email = 'awortley@michiganumc.org';

/* LOOK UP CONTACT BY EMAIL */
SELECT legacy_contacts.id AS id, legacy_contacts.first_name AS first_name, legacy_contacts.last_name, legacy_contacts.email AS email, legacy_organizations.name AS org, legacy_organizations.id AS org_id, legacy_contacts.phone AS phone
FROM legacy_contacts
LEFT JOIN legacy_organizations ON legacy_contacts.legacy_organization_id = legacy_organizations.id
WHERE legacy_contacts.email = 'rogermerrill33@gmail.com';

/* LOOK UP ALL INVITEES BY ORG ID */
SELECT invitations.id AS invitee_id, invitations.invitee_email AS invitee_email, users.name AS inviter_name, users.email AS inviter_email, legacy_organizations.name AS org_name, 'https://www.crisiscleanup.org/invitations/activate?token='||invitations.token AS activation_link, invitations.expiration, invitations.activated FROM invitations
LEFT JOIN users ON users.id = invitations.user_id
LEFT JOIN legacy_organizations ON legacy_organizations.id = invitations.organization_id
WHERE invitations.organization_id = 863;

/* LOOK UP USER BY NAME OF USER */
SELECT users.id AS id, users.name AS name, legacy_organizations.name AS org, legacy_organizations.id AS org_id, users.mobile AS phone, users.email AS email, users.encrypted_password AS pw, users.created_at, users.last_sign_in_at
FROM users 
LEFT JOIN legacy_organizations ON users.legacy_organization_id = legacy_organizations.id
WHERE users.name LIKE '%%';

/* LOOK UP INVITEE BY INVITER EMAIL */
SELECT invitations.id AS invitee_id, invitations.invitee_email AS invitee_email, users.name AS inviter_name, users.email AS inviter_email, legacy_organizations.name AS org_name, 'https://www.crisiscleanup.org/invitations/activate?token='||invitations.token AS activation_link, invitations.expiration, invitations.activated FROM invitations
LEFT JOIN users ON users.id = invitations.user_id
LEFT JOIN legacy_organizations ON legacy_organizations.id = invitations.organization_id
WHERE invitations.user_id = 
	(SELECT id
	FROM users
	WHERE email ='mharrison@brazospointe.com')
;

/* MOVE USER TO NEW ORGANIZATION  */
SET new.org_id = '1028';
SET target.email = 'elmer.dandl@gmail.com';
UPDATE users
SET legacy_organization_id = CAST(current_setting('new.org_id') AS integer)
WHERE email = current_setting('target.email');

/* POWER USERS */
SELECT DISTINCT(versions.whodunnit) AS id, users.email, users.name, COUNT(versions.whodunnit) AS edits
FROM versions
LEFT JOIN users ON users.id = CAST(versions.whodunnit AS integer)
GROUP BY versions.whodunnit, users.email, users.name
ORDER BY COUNT(versions.whodunnit) DESC;

/* POWER USERS BY INCIDENT */
SELECT versions.whodunnit AS user_id, 
  users.email AS user_email, 
    users.name AS user_name, 
    COUNT(versions.whodunnit) AS edits, 
    versions.item_id AS site_id, 
    legacy_sites.legacy_event_id, 
    legacy_events.name AS event_name
FROM versions
LEFT JOIN users ON users.id = CAST(versions.whodunnit AS integer)
LEFT JOIN legacy_sites ON legacy_sites.id = versions.item_id
LEFT JOIN legacy_events ON legacy_sites.legacy_event_id = legacy_events.id
WHERE versions.item_type = 'Legacy::LegacySite'
GROUP BY versions.whodunnit, users.email, users.name, versions.item_type, versions.item_id, legacy_sites.legacy_event_id, legacy_events.name
ORDER BY users.email, COUNT(versions.whodunnit) DESC
LIMIT 200000;

/* LOOK UP  */

/* LOOK UP  */

/* LOOK UP  */


SELECT COUNT(DISTINCT(`session_id`)) AS `texas_calls`, DATE(`time_call`) AS `date` FROM `log`
WHERE `area_code` IN(
  SELECT `code`
  FROM `area_codes`
  WHERE `state` = 'Texas')
GROUP BY DATE(`time_call`)
ORDER BY `time_call` DESC;

SELECT COUNT(DISTINCT(`session_id`)) AS `florida_calls`, DATE(`time_call`) AS `date` FROM `log`
WHERE `area_code` IN(
  SELECT `code`
  FROM `area_codes`
  WHERE `state` = 'Florida')
AND `timestamp` > '2017-09-08'
GROUP BY DATE(`time_call`)
ORDER BY `time_call` DESC;

SELECT COUNT(DISTINCT(`session_id`)) AS `florida_calls`, DATE(`time_call`) AS `date` FROM `log`
WHERE  `timestamp` > '2017-08-30'
GROUP BY DATE(`time_call`)
ORDER BY `time_call` DESC;


SELECT DATE(`log`.`time_call`) AS `date`, COUNT(DISTINCT(`log`.`session_id`)) AS `calls`, `area_codes`.`state` FROM `log`
LEFT JOIN `area_codes` ON `area_codes`.`code` = `log`.`area_code`
GROUP BY DATE(`log`.`time_call`), `area_codes`.`state`
ORDER BY `time_call` DESC;


UPDATE `phone`
SET `area_code` = LEFT(`phone_number`,3), `state` = (
  SELECT `state` 
  FROM `area_codes` 
  WHERE `area_codes`.`code` = `phone`.`area_code`)
;

/* DUMP FOR AMERICORPS */

SELECT legacy_sites.id,
  legacy_events.name as Event,
  legacy_sites.case_number AS Case_Number,
  legacy_sites.address AS Address,
  legacy_sites.city AS City,
  legacy_sites.county AS County,
  legacy_sites.state AS State,
  legacy_sites.zip_code AS Zip,
  legacy_sites.latitude AS Latitude,
  legacy_sites.longitude AS Longitude,
  legacy_sites.request_date AS Requested_Date,
  legacy_sites.status AS Status,
  legacy_sites.work_type AS Work_Type
FROM legacy_sites
LEFT JOIN legacy_events
  ON legacy_events.id = legacy_sites.legacy_event_id
LEFT JOIN legacy_organizations
  ON legacy_organizations.id = legacy_sites.claimed_by
WHERE legacy_sites.legacy_event_id = 60
AND legacy_sites.id > 59154
ORDER BY legacy_sites.id
OFFSET 0
FETCH FIRST 5000 ROWS ONLY;

/* ESTIMATE NUMBER OF VOLUNTEERS */
SET vol.lds = '750'; 
SET vol.ldscharities = '1'; 
SET vol.ldsward = '-475'; 
SET vol.org = '25'; 
SET vol.turnover = '.1'; 
SELECT(
  SELECT COUNT(legacy_organizations.id)*CAST(current_setting('vol.lds') AS integer) AS lds_volunteers 
  FROM legacy_organization_events 
  LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id WHERE legacy_organizations.name LIKE 'LDS Church%' AND legacy_organizations.is_active = 't'
)+(
  SELECT DISTINCT((SELECT COUNT(legacy_organization_events.legacy_organization_id) AS lds_volunteers 
    FROM legacy_organization_events 
    LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id WHERE legacy_organizations.name LIKE 'LDS Church%' AND legacy_organizations.is_active = 't')
  - (SELECT COUNT(DISTINCT(legacy_organization_events.legacy_organization_id))
    FROM legacy_organization_events 
    LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id WHERE legacy_organizations.name LIKE 'LDS Church%' AND legacy_organizations.is_active = 't'))*CAST(current_setting('vol.turnover') AS float)*CAST(current_setting('vol.lds') AS integer) 
  FROM legacy_organizations
)+(
  SELECT(
    SELECT COUNT(legacy_organizations.id)*CAST(current_setting('vol.ldscharities') AS integer) AS lds_charities_volunteers 
    FROM legacy_organization_events 
    LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id WHERE legacy_organizations.name LIKE 'LDS Charities%' AND is_active = 't'
    )
)+(
  SELECT DISTINCT((SELECT COUNT(legacy_organization_events.legacy_organization_id) AS lds_volunteers 
    FROM legacy_organization_events 
    LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id WHERE legacy_organizations.name LIKE 'LDS Charities%' AND legacy_organizations.is_active = 't')
  - (SELECT COUNT(DISTINCT(legacy_organization_events.legacy_organization_id))
    FROM legacy_organization_events 
    LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id WHERE legacy_organizations.name LIKE 'LDS Charities%' AND legacy_organizations.is_active = 't'))*CAST(current_setting('vol.turnover') AS float)*CAST(current_setting('vol.ldscharities') AS integer) 
  FROM legacy_organizations
)+(
  SELECT(
    SELECT COUNT(legacy_organizations.id)*CAST(current_setting('vol.ldsward') AS integer) AS lds_ward_volunteers 
    FROM legacy_organization_events 
    LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id WHERE legacy_organizations.name LIKE '%Ward%' AND is_active = 't'
  )
)+(
  SELECT DISTINCT((SELECT COUNT(legacy_organization_events.legacy_organization_id) AS lds_volunteers 
    FROM legacy_organization_events 
    LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id WHERE legacy_organizations.name LIKE '%Ward%' AND legacy_organizations.is_active = 't')
  - (SELECT COUNT(DISTINCT(legacy_organization_events.legacy_organization_id))
    FROM legacy_organization_events 
    LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id WHERE legacy_organizations.name LIKE '%Ward%' AND legacy_organizations.is_active = 't'))*CAST(current_setting('vol.turnover') AS float)*CAST(current_setting('vol.ldsward') AS integer) 
  FROM legacy_organizations
)+(
  SELECT (COUNT(id) - (
    SELECT COUNT(legacy_organizations.id) AS lds_charities_volunteers 
    FROM legacy_organization_events 
    LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id WHERE legacy_organizations.name LIKE 'LDS Charities%' OR legacy_organizations.name LIKE 'LDS%' OR legacy_organizations.name LIKE '%Ward%' OR legacy_organizations.name LIKE 'Local Admin%')
  )*CAST(current_setting('vol.org') AS integer) 
  FROM legacy_organizations 
  WHERE name NOT LIKE 'Local Admin%' AND is_active = 't'
)+(

  SELECT (COUNT(id) - (
    SELECT COUNT(DISTINCT(legacy_organization_events.legacy_organization_id))
      FROM legacy_organization_events 
      LEFT JOIN legacy_organizations ON legacy_organization_events.legacy_organization_id = legacy_organizations.id WHERE legacy_organizations.name  LIKE 'LDS Charities%' OR legacy_organizations.name LIKE 'LDS%' OR legacy_organizations.name LIKE '%Ward%' OR legacy_organizations.name LIKE 'Local Admin%' AND legacy_organizations.is_active = 't')
  )*CAST(current_setting('vol.turnover') AS float)*CAST(current_setting('vol.org') AS integer)
  FROM legacy_organizations
  WHERE name NOT LIKE 'Local Admin%' AND is_active = 't'
) AS volunteer_count;


/* DOWNLOAD OLD WORK ORDERS FOR CALL-DOWNS */
SET target.event_id = '60';
SELECT legacy_events.name as Event,
  legacy_sites.case_number AS Case_Number,
  legacy_sites.updated_at AS Last_Updated,
  legacy_sites.request_date AS Requested_Date,
  legacy_sites.name AS Name,
  legacy_sites.address AS Address,
  legacy_sites.city AS City,
  legacy_sites.county AS County,
  legacy_sites.state AS State,
  legacy_sites.zip_code AS Zip,
  legacy_sites.phone1 AS Phone_1,
  legacy_sites.phone2 AS Phone_2,
  legacy_sites.reported_by AS Reported_By,
  legacy_organizations.name AS Claimed_By,
  legacy_sites.status AS Status,
  legacy_sites.work_type AS Work_Type
FROM legacy_sites
LEFT JOIN legacy_events
  ON legacy_events.id = legacy_sites.legacy_event_id
LEFT JOIN legacy_organizations
  ON legacy_organizations.id = legacy_sites.claimed_by
WHERE legacy_sites.legacy_event_id = CAST(current_setting('target.event_id') AS integer)
AND legacy_sites.status LIKE 'Open%'
ORDER BY legacy_sites.updated_at ASC;

SELECT legacy_events.name as Event,
  legacy_sites.case_number AS Case_Number,
  legacy_sites.updated_at AS Last_Updated,
  legacy_sites.request_date AS Requested_Date,
  legacy_sites.name AS Name,
  legacy_sites.address AS Address,
  legacy_sites.city AS City,
  legacy_sites.county AS County,
  legacy_sites.state AS State,
  legacy_sites.zip_code AS Zip,
  legacy_sites.phone1 AS Phone_1,
  legacy_sites.phone2 AS Phone_2,
  legacy_sites.reported_by AS Reported_By,
  legacy_organizations.name AS Claimed_By,
  legacy_sites.status AS Status,
  legacy_sites.work_type AS Work_Type
FROM legacy_sites
LEFT JOIN legacy_events
  ON legacy_events.id = legacy_sites.legacy_event_id
LEFT JOIN legacy_organizations
  ON legacy_organizations.id = legacy_sites.claimed_by
WHERE legacy_sites.legacy_event_id = 60
AND legacy_sites.status LIKE 'Open%'
ORDER BY legacy_sites.updated_at ASC
LIMIT 0,5000;
