class AddOrgIdToInvit < ActiveRecord::Migration
  def change
  	add_column :invitations, :organization_id, :integer, null: false
  	add_column :users, :verified, :boolean, default: false
  end
end
