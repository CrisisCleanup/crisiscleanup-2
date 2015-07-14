class OrgIdCanBeNullInContacts < ActiveRecord::Migration
  def change
  	change_column_null :legacy_contacts, :legacy_organization_id, true
  end
end
