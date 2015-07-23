class AddZipCodeToLegacySites < ActiveRecord::Migration
  def change
  	add_column :legacy_sites, :zip_code, :string
  end
end
