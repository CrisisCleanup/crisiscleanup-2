class AddRolesToLegacyOrganization < ActiveRecord::Migration
  def change
  	add_column :legacy_organizations, :does_damage_assessment, :boolean
  	add_column :legacy_organizations, :does_intake_assessment, :boolean
  	add_column :legacy_organizations, :does_cleanup, :boolean
  	add_column :legacy_organizations, :does_follow_up, :boolean
  	add_column :legacy_organizations, :does_minor_repairs, :boolean
  	add_column :legacy_organizations, :does_rebuilding, :boolean
  	add_column :legacy_organizations, :does_coordination, :boolean
  	add_column :legacy_organizations, :government, :boolean
  	add_column :legacy_organizations, :does_other_activity, :boolean
  	add_column :legacy_organizations, :where_are_you_working, :string

  	remove_column :legacy_organizations, :does_only_coordination
  	remove_column :legacy_organizations, :does_only_sit_aware
  	remove_column :legacy_organizations, :does_recovery
  	remove_column :legacy_organizations, :does_something_else
  end
end
