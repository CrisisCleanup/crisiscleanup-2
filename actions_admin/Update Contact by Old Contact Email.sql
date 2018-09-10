SET old.contact_email = '';
SET new.contact_first_name = '';
SET new.contact_last_name = '';
SET new.contact_phone = '';
SET new.contact_email = '';
UPDATE legacy_contacts
SET first_name = current_setting('new.contact_first_name'), last_name = current_setting('new.contact_last_name'), email = current_setting('new.contact_email'), phone = current_setting('new.contact_phone'), is_primary = 't'
WHERE email = current_setting('old.contact_email');