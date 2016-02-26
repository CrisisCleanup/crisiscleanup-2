class AddReferralAndPublishableToLegacyOrganizations < ActiveRecord::Migration
  def change
  	add_column :legacy_organizations, :referral, :string
  	add_column :legacy_organizations, :publishable, :boolean
  end
end
