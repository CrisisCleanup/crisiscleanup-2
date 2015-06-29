class CreateLegacyEvents < ActiveRecord::Migration
  def change
    create_table :legacy_events do |t|
      t.string :case_label , null: false
      t.string :counties , array: true, default: []
      t.string :name, null: false
      t.string :short_name, null: false
      t.date :created_date, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :num_sites
      t.string :reminder_contents
      t.integer :reminder_days
      t.timestamps null: false
    end
  end
end
