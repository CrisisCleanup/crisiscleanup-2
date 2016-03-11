class AddPasswordHashListToLegacyOrg < ActiveRecord::Migration
  def change
  	add_column :legacy_organizations, :_password_hash_list, :string
  end
end
