class LegacyOrganizationEvents < ActiveRecord::Migration
  def change
  	create_table :legacy_organization_events do |t|
  		t.integer :legacy_organization_id, null: false
  		t.integer :legacy_event_id, null: false
  	end
  end
end
