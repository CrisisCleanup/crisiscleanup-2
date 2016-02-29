class AddWorkRequestedToLegacySites < ActiveRecord::Migration
  def change
    rename_column :legacy_sites, :phone, :phone1
    add_column :legacy_sites, :phone2, :string
    add_column :legacy_sites, :work_requested, :string
  end
end
