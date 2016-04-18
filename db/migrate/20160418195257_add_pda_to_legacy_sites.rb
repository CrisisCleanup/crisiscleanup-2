class AddPdaToLegacySites < ActiveRecord::Migration
  def change
  	add_column :legacy_sites, :pda, :boolean, default: false # preliminary damage assessment
  end
end
