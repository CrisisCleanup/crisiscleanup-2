class AddTimestampsToContact < ActiveRecord::Migration
  def change
    change_table :legacy_contacts do |t|
  	  t.timestamps
  	end
  end
end
