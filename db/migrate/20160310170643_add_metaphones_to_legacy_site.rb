class AddMetaphonesToLegacySite < ActiveRecord::Migration
  def change
    add_column :legacy_sites, :name_metaphone, :string
    add_column :legacy_sites, :city_metaphone, :string
    add_column :legacy_sites, :county_metaphone, :string
    add_column :legacy_sites, :address_metaphone, :string
  end
end
