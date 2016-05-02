class AddActivatedToInvitation < ActiveRecord::Migration
  def change
  	add_column :invitations, :activated, :boolean, default: false
  end
end
