class AddTitleToUser < ActiveRecord::Migration
  def change
    add_column :users, :title, :string
  end
end
