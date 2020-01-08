class AddUserRequestedToRedeployRequest < ActiveRecord::Migration
  def change
    add_column :redeploy_requests, :user_id, :integer
  end
end
