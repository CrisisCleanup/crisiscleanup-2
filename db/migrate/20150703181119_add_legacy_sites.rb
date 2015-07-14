class AddLegacySites < ActiveRecord::Migration
  def change
    create_table :legacy_sites do |t|
      t.string :address , null: false
      t.float :blurred_latitude, null: false
      t.float :blurred_longitude, null: false
      t.string :case_number, null: false
      t.string :city, null: false
      t.integer :claimed_by
      t.integer :legacy_event_id, null: false
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.string :name, null: false
      t.string :phone, null: false
	  t.integer :reported_by, null: false      
      t.date :requested_at, null: false
      t.string :state, null: false
      t.string :status, null: false
      t.string :work_type, null: false, default: "Other"
      t.hstore :data
      t.timestamps null: false
    end
  end
end
