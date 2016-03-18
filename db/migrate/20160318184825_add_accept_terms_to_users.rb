class AddAcceptTermsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :accepted_terms, :boolean
 	add_column :users, :accepted_terms_timestamp, :datetime
  end
end
