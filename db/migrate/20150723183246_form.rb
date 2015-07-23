class Form < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.integer :legacy_event_id, null: false
      t.text :html
    end
  end
end
