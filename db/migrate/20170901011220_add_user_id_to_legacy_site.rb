class AddUserIdToLegacySite < ActiveRecord::Migration
  def change
    add_column :legacy_sites, :user_id, :integer
  end
end
