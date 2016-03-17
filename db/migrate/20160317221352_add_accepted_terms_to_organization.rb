class AddAcceptedTermsToOrganization < ActiveRecord::Migration
  def change
  	add_column :legacy_organizations, :accepted_terms, :boolean
 	add_column :legacy_organizations, :accepted_terms_timestamp, :datetime
  end
end
