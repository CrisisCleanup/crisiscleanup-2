class ConsolidateMigrationsForApiImport < ActiveRecord::Migration
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

  	add_column :legacy_sites, :request_date, :date 

    change_column_null :legacy_sites, :phone, true
    change_column_null :legacy_sites, :reported_by, true
    change_column_null :legacy_sites, :requested_at, true

    change_column_null :legacy_organizations, :activate_by, true
    change_column_null :legacy_organizations, :activated_at, true
    change_column_null :legacy_organizations, :activation_code, true
    change_column_null :legacy_organizations, :admin_notes, true
    change_column_null :legacy_organizations, :address, true
    change_column_null :legacy_organizations, :city, true
    change_column_null :legacy_organizations, :email, true
    change_column_null :legacy_organizations, :phone, true
    change_column_null :legacy_organizations, :physical_presence, true
    change_column_null :legacy_organizations, :publish, true
    change_column_null :legacy_organizations, :reputable, true
    change_column_null :legacy_organizations, :state, true
    change_column_null :legacy_organizations, :work_area, true
    change_column_null :legacy_organizations, :zip_code, true

    change_column_null :legacy_events, :end_date, true
    add_column :legacy_events, :timestamp_last_login, :datetime   

    add_column :legacy_events, :appengine_key, :string

    add_column :legacy_organizations, :appengine_key, :string

    add_column :legacy_sites, :appengine_key, :string

    add_column :legacy_contacts, :appengine_key, :string    

  end
end
