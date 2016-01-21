class AddExpirationToInvitation < ActiveRecord::Migration
  def change
  	add_column :invitations, :expiration, :datetime
  end
end
