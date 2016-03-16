module Legacy
  class LegacyEvent < ActiveRecord::Base
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

    def sites_to_csv
      if legacy_sites.size > 0
        CSV.generate(headers: true) do |csv|
          # Generate the header
          header = legacy_sites[0].attribute_names.select do |attr|
            !["name_metaphone", "city_metaphone", "county_metaphone", "address_metaphone"].include? attr
          end
          csv << header

          # Generate the data rows
          legacy_sites.each do |site|
            csv << site.attributes.values
          end
        end
      end
    end
  end
end
