class AddAuditModel < ActiveRecord::Migration
  def change
    create_table :audits do |t|
    	t.integer :user_id
    	t.string :action
    end
  end
end
