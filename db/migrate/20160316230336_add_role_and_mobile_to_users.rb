class AddRoleAndMobileToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :role, :string
  	add_column :users, :mobile, :string
  end
end
