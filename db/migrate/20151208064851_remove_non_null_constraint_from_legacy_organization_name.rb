class RemoveNonNullConstraintFromLegacyOrganizationName < ActiveRecord::Migration
  def change
  	change_column :legacy_organizations, :name, :string, :null => true
  end
end
