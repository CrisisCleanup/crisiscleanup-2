class AddTimestampLastLoginToEvent < ActiveRecord::Migration
  def change
    add_column :legacy_events, :timestamp_last_login, :datetime  	
  end
end
