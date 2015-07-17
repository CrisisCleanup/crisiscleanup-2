class LegacyContact < ActiveRecord::Migration
  def change
  	create_table :legacy_contacts do |t|
  	  t.string :email , null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :legacy_organization_id, null: false
      t.boolean :is_primary, default: false
	    t.string :phone, null: false
  	end
  end
end
