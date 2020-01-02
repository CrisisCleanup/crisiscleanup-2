class CreateRedeployRequests < ActiveRecord::Migration
  def change
    create_table :redeploy_requests do |t|
      t.integer :legacy_organization_id
      t.integer :legacy_event_id
      t.string :token
      t.integer :accepted_by, null: true
      t.boolean :accepted, null: true

      t.timestamps null: false
    end
  end
end
