class AddIndexesToLegacySitesAndLegacyOrganizations < ActiveRecord::Migration
  def change
    add_index :legacy_sites, :claimed_by
    add_index :legacy_sites, :reported_by
    add_index :legacy_sites, :legacy_event_id
  end
end
