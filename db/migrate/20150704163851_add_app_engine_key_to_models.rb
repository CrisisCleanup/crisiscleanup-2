class AddAppEngineKeyToModels < ActiveRecord::Migration
  def change
    add_column :legacy_events, :appengine_key, :string

    add_column :legacy_organizations, :appengine_key, :string

    add_column :legacy_sites, :appengine_key, :string

    add_column :legacy_contacts, :appengine_key, :string  	
  end
end
