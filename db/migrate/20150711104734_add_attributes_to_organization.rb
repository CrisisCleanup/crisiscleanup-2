class AddAttributesToOrganization < ActiveRecord::Migration
  def change
  	add_column :legacy_organizations, :voad_member, :boolean
  	add_column :legacy_organizations, :mold_treatment, :boolean
  	add_column :legacy_organizations, :tree_removal, :boolean
  	add_column :legacy_organizations, :design, :boolean
  	add_column :legacy_organizations, :replace_appliances, :boolean
  	add_column :legacy_organizations, :canvass, :boolean
  	add_column :legacy_organizations, :sanitizing, :boolean
  	add_column :legacy_organizations, :exterior_debris, :boolean
  	add_column :legacy_organizations, :water_pumping, :boolean
  	add_column :legacy_organizations, :appropriate_work, :boolean
  	add_column :legacy_organizations, :reconstruction, :boolean
  	add_column :legacy_organizations, :interior_debris, :boolean
  	add_column :legacy_organizations, :assessment, :boolean
  	add_column :legacy_organizations, :muck_out, :boolean
  	add_column :legacy_organizations, :permission, :string
  	add_column :legacy_organizations, :refurbishing, :boolean
  	add_column :legacy_organizations, :clean_up, :boolean
  	add_column :legacy_organizations, :mold_abatement, :boolean
  	add_column :legacy_organizations, :permits, :boolean
  	add_column :legacy_organizations, :replace_furniture, :boolean
  	add_column :legacy_organizations, :gutting, :boolean
  	add_column :legacy_organizations, :number_volunteers, :string
  	add_column :legacy_organizations, :primary_contact_email, :string
  	add_column :legacy_organizations, :voad_member_url, :string
  end
end
