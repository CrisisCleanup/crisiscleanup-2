SET old.contact_email = '';
SET the.org_id = '';
DELETE FROM legacy_contacts WHERE legacy_contacts.email = CAST(current_setting('old.contact_email') AS text) AND legacy_contacts.legacy_organization_id = CAST(current_setting('the.org_id') AS integer);