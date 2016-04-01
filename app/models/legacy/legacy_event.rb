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
      sites = legacy_sites
      if sites.size > 0
        CSV.generate(headers: true) do |csv|
          # Generate the header
          header = [
            "Event",
            "Case #",
            "Address",
            "City",
            "County",
            "State",
            "Zip",
            "Phone 1",
            "Phone 2",
            "Latitude",
            "Longitude",
            "Blurred Lat",
            "Blurred Lng",
            "Reported By",
            "Claimed By",
            "Requested Date",
            "Status",
            "Work Type",
            "Work Requested",
            "Details"
          ]
          csv << header

          # Generate the data rows
          sites.each do |site|
            record = [
              self.name,
              site.case_number,
              site.address,
              site.city,
              site.county,
              site.state,
              site.zip_code,
              site.phone1,
              site.phone2,
              site.latitude,
              site.longitude,
              site.blurred_latitude,
              site.blurred_longitude,
              # TODO: reported_by and claimed_by need to be the org names not ids
              site.reported_by,
              site.claimed_by,
              site.request_date,
              site.status,
              site.work_type,
              site.work_requested,
              site.data.map do |datum|
                next if [
                  "address_digits",
                  "address_metaphone",
                  "assigned_to",
                  "city_metaphone",
                  "claim_for_org",
                  "county",
                  "cross_street",
                  "damage_level",
                  "date_closed",
                  "do_not_work_before",
                  "event",
                  "event_name",
                  "habitable",
                  "hours_worked_per_volunteer",
                  "ignore_similar",
                  "initials_of_resident_present",
                  "inspected_by",
                  "landmark",
                  "member_of_assessing_organization",
                  "modified_by",
                  "name_metaphone",
                  "phone1",
                  "phone2",
                  "phone_normalised",
                  "prepared_by",
                  "priority",
                  "release_form",
                  "temporary_address",
                  "time_to_call",
                  "total_loss",
                  "total_volunteers",
                  "unrestrained_animals",
                  "work_requested",
                  "zip_code"
                ].include? datum[0]
                next if datum[1].blank?
                next if datum[1] == "n"
                next if datum[1] == "0"
                datum[0].gsub("_", " ").humanize + ": " + datum[1].gsub("_", " ").humanize
              end.compact.reject(&:blank?).join(", ")
            ]
            csv << record
          end
        end
      end
    end
  end
end
