class OrganizationActiveDefaultToFalse < ActiveRecord::Migration
  def change
  	change_column :legacy_organizations, :is_active, :boolean, :default => false
  end
end
