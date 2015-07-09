class AddLegacyOrganization < ActiveRecord::Migration
  def change
  	create_table :legacy_organizations do |t|
      t.date :activate_by, null: false
      t.date :activated_at, null: false      
      t.string :activation_code , null: false
      t.string :address, null: false
      t.string :admin_notes
      t.string :city , null:false
      t.boolean :deprecated, default: false
	  t.boolean :does_only_coordination, default: false
	  t.boolean :does_only_sit_aware, default: false
	  t.boolean :does_recovery, default: false
	  t.boolean :does_something_else, default: false
	  t.string :email , null:false
	  t.string :facebook
	  t.boolean :is_active, null: false
	  t.boolean :is_admin, default: false
      t.float :latitude, null:false
      t.float :longitude, null:false
      t.string :name, null: false
      t.boolean :not_an_org, default: false
	  t.boolean :only_session_authentication, default: false
	  t.boolean :org_verified, default: false
	  t.string :password, null: false
      t.string :permissions, null: false
      t.string :phone, null:false
      t.boolean :physical_presence, null: false
	  t.boolean :publish, null:false 
	  t.boolean :reputable, null:false 
	  t.string :state, null:false
	  t.string :terms_privacy
	  t.datetime :timestamp_login
      t.datetime :timestamp_signup, null: false
      t.string :twitter
      t.string :url
      t.text :voad_referral
      t.string :work_area, null: false
      t.string :zip_code, null: false
      t.timestamps null: false
    end
  end
end
