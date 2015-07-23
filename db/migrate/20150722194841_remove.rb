class Remove < ActiveRecord::Migration
  def change
  	change_column_null :legacy_organizations, :latitude, true
    change_column_null :legacy_organizations, :longitude, true
    change_column_null :legacy_organizations, :password, true
    change_column_null :legacy_organizations, :permissions, true
    change_column_null :legacy_organizations, :timestamp_signup, true
     change_column_null :users, :legacy_organization_id, true
  	
  end
end
