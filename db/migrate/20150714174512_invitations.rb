class Invitations < ActiveRecord::Migration
  def change
  	create_table :invitations do |t|
  		t.integer :user_id
  		t.string :invitee_email
  		t.string :token, null: false
  	end
  end
end
