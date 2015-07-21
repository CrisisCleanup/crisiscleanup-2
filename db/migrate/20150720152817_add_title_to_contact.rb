class AddTitleToContact < ActiveRecord::Migration
  def change
  	add_column :legacy_contacts, :title, :string
  end
end
