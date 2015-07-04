class RemoveOrganizationNonNullConstraints < ActiveRecord::Migration
  def change
  	change_column_null :legacy_organizations, :activate_by, true
  	change_column_null :legacy_organizations, :activated_at, true
  	change_column_null :legacy_organizations, :activation_code, true
  	change_column_null :legacy_organizations, :admin_notes, true
  	change_column_null :legacy_organizations, :address, true
  	change_column_null :legacy_organizations, :city, true
  	change_column_null :legacy_organizations, :email, true
  	change_column_null :legacy_organizations, :phone, true
  	change_column_null :legacy_organizations, :physical_presence, true
  	change_column_null :legacy_organizations, :publish, true
  	change_column_null :legacy_organizations, :reputable, true
  	change_column_null :legacy_organizations, :state, true
 	change_column_null :legacy_organizations, :work_area, true
 	change_column_null :legacy_organizations, :zip_code, true
  end
end
