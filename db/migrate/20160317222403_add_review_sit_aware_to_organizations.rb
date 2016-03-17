class AddReviewSitAwareToOrganizations < ActiveRecord::Migration
  def change
  	add_column :legacy_organizations, :review_other_organizations, :boolean
  	add_column :legacy_organizations, :situational_awareness, :boolean
  end
end
