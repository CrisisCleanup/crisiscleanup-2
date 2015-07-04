class RemoveNonNullConstraintFromLegacyEventEndDate < ActiveRecord::Migration
  def change
  	change_column_null :legacy_events, :end_date, true
  end
end
