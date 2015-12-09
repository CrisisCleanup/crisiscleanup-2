class CreateRequestInvitation < ActiveRecord::Migration
  def change
    create_table :request_invitations do |t|
    	t.string :name
    	t.string :email
    	t.integer :legacy_organization_id
    	t.boolean :user_created, default: false
    	t.boolean :invited, default: false
    	t.timestamps null: false
    end
  end
end
