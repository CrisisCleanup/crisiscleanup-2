class AddOrgTitleToContacts < ActiveRecord::Migration
  def change
  	add_column :legacy_contacts, :organizational_title, :string
  end
end
