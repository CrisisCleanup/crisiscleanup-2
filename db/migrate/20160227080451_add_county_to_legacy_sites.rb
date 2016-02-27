class AddCountyToLegacySites < ActiveRecord::Migration
  def change
  	add_column :legacy_sites, :county, :string
  end
end
