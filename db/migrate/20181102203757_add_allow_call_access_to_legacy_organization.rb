class AddAllowCallAccessToLegacyOrganization < ActiveRecord::Migration
  def change
  	add_column :legacy_organizations, :allow_caller_access, :boolean
  end
end
