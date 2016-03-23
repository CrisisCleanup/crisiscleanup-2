class AddLegacyAttributesToOrg < ActiveRecord::Migration
  def change
  	add_column :legacy_organizations, :does_recovery, :boolean
  	add_column :legacy_organizations, :does_only_coordination, :boolean
  	add_column :legacy_organizations, :does_only_sit_aware, :boolean
  	add_column :legacy_organizations, :does_something_else, :boolean
  end
end
