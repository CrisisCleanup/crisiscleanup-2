class CreateTemporaryPassword < ActiveRecord::Migration
  def change
    create_table :temporary_passwords do |t|
    	t.integer :created_by
    	t.integer :legacy_organization_id
    	t.string :password
    	t.string :password_confirmation
    	t.string :password_digest
    	t.datetime :expires
    end
  end
end
