class AddDateClosedToSites < ActiveRecord::Migration
  def change
  	add_column :legacy_sites, :date_closed, :date
  end
end
