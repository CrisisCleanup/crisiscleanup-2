class CreatePrintTokens < ActiveRecord::Migration
  def change
    create_table :print_tokens do |t|
      t.integer :legacy_site_id
      t.integer :printing_org_id
      t.integer :printing_user_id
      t.string :token
      t.datetime :last_visted
      t.string :reporting_email
      t.string :reporting_org_name
      t.string :reporting_phone
      t.string :reporting_name
      t.datetime :token_expiration

      t.timestamps null: false
    end
  end
end
