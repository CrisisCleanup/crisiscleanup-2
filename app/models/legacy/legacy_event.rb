module Legacy
  class LegacyEvent < ApplicationRecord
    default_scope { order('start_date DESC') }
    self.per_page = 500
    has_paper_trail
    has_many :legacy_organization_events
    has_many :legacy_sites
    has_many :legacy_organizations, through: :legacy_organization_events
    has_one :form,
      inverse_of: :legacy_event
    validates_presence_of :name, :case_label, :created_date, :start_date

    CASE_LABELS = %w(A B C D E F G H J K M N Q R S T U V W X Y Z)
    def self.next_case_label
      CASE_LABELS[self.count % 22]
    end

  end
end
