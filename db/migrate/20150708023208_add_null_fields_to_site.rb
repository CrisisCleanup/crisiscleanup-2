class AddNullFieldsToSite < ActiveRecord::Migration
  def change
  	change_column_null :legacy_sites, :phone, true
  	change_column_null :legacy_sites, :reported_by, true
  	change_column_null :legacy_sites, :requested_at, true
  	change_column_null :legacy_sites, :work_type, true

  end
end
