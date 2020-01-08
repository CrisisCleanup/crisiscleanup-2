class AddRegistrationIpToLegacyOrganization < ActiveRecord::Migration
  def change
  	add_column :legacy_organizations, :registration_ip, :string
  end
end
