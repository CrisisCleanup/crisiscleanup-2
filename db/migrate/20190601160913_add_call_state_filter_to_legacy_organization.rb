class AddCallStateFilterToLegacyOrganization < ActiveRecord::Migration
  def change
  	add_column :legacy_organizations, :call_state_filter, :string
  end
end
