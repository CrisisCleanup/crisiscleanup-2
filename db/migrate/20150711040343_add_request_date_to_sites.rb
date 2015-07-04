class AddRequestDateToSites < ActiveRecord::Migration
  def change
  	add_column :legacy_sites, :request_date, :date 	
  end
end
