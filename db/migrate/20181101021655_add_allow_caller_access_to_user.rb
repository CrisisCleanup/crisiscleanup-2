class AddAllowCallerAccessToUser < ActiveRecord::Migration
  def change
  	add_column :users, :allow_caller_access, :boolean
  end
end
