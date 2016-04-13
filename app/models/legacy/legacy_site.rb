module Legacy
  class LegacySite < ActiveRecord::Base
    has_paper_trail
    # geocoded_by :full_street_address
    validates_presence_of :address, :blurred_latitude, :blurred_longitude, :case_number, :city, :latitude, :longitude, :name, :work_type, :status
    # before_validation :geocode, if: -> (obj) { obj.latitude.nil? or obj.longitude.nil? or obj.address_changed? }
    before_validation :create_blurred_geocoordinates
    before_validation :add_case_number
    before_save :calculate_metaphones
    before_save :calculate_request_date
    before_create :detect_duplicates
    belongs_to :legacy_event
    belongs_to :legacy_organization, foreign_key: :claimed_by
    belongs_to :reporting_org, class_name: "Legacy::LegacyOrganization", foreign_key: :reported_by

    # These are just to get around simple_form junk. Remove them once simple_form is gone.
    # So we can hide the autofill on this model's simple_form - I don't think this is actually working.
    attr_accessor :autofill_disable
    attr_accessor :claim
    attr_accessor :skip_duplicates

    def full_street_address
      "#{self.address}, #{self.city}, #{self.state}"
    end

    def add_case_number
      if self.legacy_event_id && self.case_number.blank?
        count = Legacy::LegacySite.where(legacy_event_id: self.legacy_event_id).pluck(:case_number).map { |x| x[/\d+/].to_i }.max
        count = 0 if count.nil?
        event_case_label = Legacy::LegacyEvent.find(self.legacy_event_id).case_label
        self.case_number = "#{event_case_label}#{count + 1}"
      end
    end

    def calculate_metaphones
      self.name_metaphone = Text::Metaphone.metaphone(self.name) unless self.name.nil? == true
      self.city_metaphone = Text::Metaphone.metaphone(self.city) unless self.city.nil? == true
      self.county_metaphone = Text::Metaphone.metaphone(self.county) unless self.county.nil? == true
      self.address_metaphone = Text::Metaphone.metaphone(self.address) unless self.address.nil? == true
    end

    def calculate_request_date
      if self.request_date.blank?
        self.request_date = Time.now
      end
    end

    def create_blurred_geocoordinates
      self.blurred_latitude = self.latitude + rand(-0.0187..0.0187) if self.latitude
      self.blurred_longitude = self.longitude + rand(-0.0187..0.0187) if self.longitude
    end

    def claimed_by_org
      LegacyOrganization.find(self.claimed_by)
    end

    def detect_duplicates
      unless self.skip_duplicates.to_i == 1
        # Lat/Lon OR Name Metaphone OR Phone OR (Street Number AND Address Metaphone AND (City Metaphone OR County Metaphone OR Zip))
        dups = Legacy::LegacySite
                .where('legacy_event_id = :event_id
                  AND (
                    (
                      ROUND(CAST("latitude" as NUMERIC),4) = ROUND(:latitude, 4)
                        AND
                      ROUND(CAST("longitude" as NUMERIC),4) = ROUND(:longitude, 4)
                    )
                    OR name_metaphone = :name
                    OR (phone1 = :phone OR phone2 = :phone)
                    OR (
                      address LIKE :address_number
                      AND address_metaphone = :address
                      AND (
                        city_metaphone = :city
                        OR county_metaphone = :county
                        OR zip_code = :zip
                      )
                    )
                  )',
                  {
                    event_id: self.legacy_event_id,
                    latitude: self.latitude,
                    longitude: self.longitude,
                    name: self.name_metaphone,
                    phone: self.phone1,
                    address_number: (/\d+/.match(self.address))[0] + '%',
                    address: self.address_metaphone,
                    city: self.city_metaphone,
                    county: self.county_metaphone,
                    zip: self.zip_code
                  }
                )
        if dups.count > 0
          dups.each do |dup|
            errors.add(:duplicates, {
                id: dup.id,
                case_number: dup.case_number,
                event_id: dup.legacy_event_id,
                address: dup.address
              })
          end
          return false
        end
      end
    end

    def reported_by_org
      LegacyOrganization.find(self.reported_by)
    end

    def self.csv_header
      CSV::Row.new(
        [
          :event,
          :case_number,
          :address,
          :city,
          :county,
          :state,
          :zip_code,
          :phone1,
          :phone2,
          :latitude,
          :longitude,
          :blurred_latitude,
          :blurred_longitude,
          :reported_by,
          :claimed_by,
          :request_date,
          :status,
          :work_type,
          :work_requested,
          :details
        ],[
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
        ],
        true)
    end

    def to_csv_row
      data = [] if data.nil?

      begin
      CSV::Row.new(
        [
          :event,
          :case_number,
          :address,
          :city,
          :county,
          :state,
          :zip_code,
          :phone1,
          :phone2,
          :latitude,
          :longitude,
          :blurred_latitude,
          :blurred_longitude,
          :reported_by,
          :claimed_by,
          :request_date,
          :status,
          :work_type,
          :work_requested,
          :details
        ],[
          legacy_event.name,
          case_number,
          address,
          city,
          county,
          state,
          zip_code,
          phone1,
          phone2,
          latitude,
          longitude,
          blurred_latitude,
          blurred_longitude,
          reporting_org.try(:name),
          legacy_organization.try(:name),
          request_date,
          status,
          work_type,
          work_requested,
          data.map do |datum|
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
      )
    rescue Exception => e
      puts case_number
      puts e.message
    end
    end

    def self.find_in_batches(filters, batch_size, &block)
      includes(:legacy_event, :legacy_organization, :reporting_org)
      .where(filters)
      .find_each(batch_size: batch_size) do |sites|
        yield sites
      end
    end

    def self.statuses_by_event event_id
      distinct_attribute_by_event_id "status", event_id
    end

    def self.work_types_by_event event_id
      distinct_attribute_by_event_id "work_type", event_id
    end

    def self.distinct_attribute_by_event_id attribute, event_id
      Legacy::LegacySite.where(legacy_event_id: event_id).select("distinct #{attribute}")
    end

    def self.status_counts event_id
      status_counts_hash = {}
      statuses_by_event(event_id).each do |status|
        status_counts_hash[status.status] = status_counts_by_event status, event_id
      end
      status_counts_hash
    end

    def self.work_type_counts event_id
      work_type_counts_hash = {}
      work_types_by_event(event_id).each do |work_type|
        work_type_counts_hash[work_type.work_type] = work_type_counts_by_event work_type, event_id
      end
      work_type_counts_hash
    end

    def self.status_counts_by_event status, event_id
      count = Legacy::LegacySite.where(legacy_event_id: event_id, status: status.status).count
    end

    def self.work_type_counts_by_event work_type, event_id
      count = Legacy::LegacySite.where(legacy_event_id: event_id, work_type: work_type.work_type).count
    end

    def self.todays_create_and_edit_count
      count = Legacy::LegacySite.where("DATE(updated_at) = ?", Date.today).count
    end

    def self.open_by_organization organization_id
      count = 0
      Legacy::LegacySite.where(claimed_by: organization_id).each do |site|
        if site.status.include? "Open"
          count +=1
        end
      end
      count
    end

    def self.closed_by_organization organization_id
      count = 0
      Legacy::LegacySite.where(claimed_by: organization_id).each do |site|
        if site.status.include? "Closed"
          count +=1
        end
      end
      count
    end

    def self.to_csv(options = {}, params)
      CSV.generate(options) do |csv|
        csv_column_names = get_column_names(params)
        csv << csv_column_names
        orgs_hash = {}
        Legacy::LegacyOrganization.select(:id, :name).each do |org|
          orgs_hash[org.id] = org.name
        end
        all.each do |site|
          csv << site_to_hash(site.attributes, orgs_hash).values_at(*csv_column_names)
        end
      end
    end

    def self.site_to_hash site_attributes, orgs_hash = None
      if site_attributes["data"]
        site_attributes['data'].each do |key, value|
          site_attributes[key] = value
        end
      end
      site_attributes.delete('data')
      site_attributes.delete('event')
      if orgs_hash
        claimed_by_id = site_attributes['claimed_by']
        reported_by_id = site_attributes['reported_by']
        site_attributes["claimed_by"] = orgs_hash[claimed_by_id]
        site_attributes["reported_by"] = orgs_hash[reported_by_id]
      end
      site_attributes
    end

    def self.import(file, dup_check_method, dup_handler, event_id)
      header = []
      # Throw away the top row of the legacy export csv
      CSV.parse(File.readlines(file.path).drop(1).join) do |row|
        # Assume the first row is the header
        if header.empty?
          header = row
        else
          hashed_row = Hash[header.zip row]
          if dup_check_method
            check_update(hashed_row, dup_check_method, dup_handler, event_id)
          else
            create_from_row(hashed_row, event_id)
          end
        end
      end
    end

    def self.check_update(hashed_row, dup_check_method, dup_handler, event_id)
      if site = search_duplicate(hashed_row, dup_check_method)
        update_from_row(site, hashed_row, dup_handler)
      else
        create_from_row(hashed_row, event_id)
      end
    end

    def self.create_from_row(hashed_row, event_id)
      Legacy::LegacySite.create! hash_to_site(hashed_row, event_id)
    end

    def self.update_from_row(site, hashed_row, dup_handler)
      case dup_handler
      when "references"
        site.update(claimed_by: hashed_row[:claimed_by], reported_by: hashed_row[:reported_by])
      when "references_and_work_type"
        site.update(work_type: hashed_row["work_type"], claimed_by: hashed_row[:claimed_by], reported_by: hashed_row[:reported_by])
      when "replace_all"
        site.update(hash_to_site(hashed_row))
      else
        raise "Improperly formatted duplicate method."
      end
    end

    def self.search_duplicate(hashed_row, dup_check_method)
      case dup_check_method
      when "name_lat_lng"
        return Legacy::LegacySite.find_by(name: hashed_row["name"], latitude: hashed_row["latitude"], longitude: hashed_row["longitude"])
      when "lat_lng"
        return Legacy::LegacySite.find_by(latitude: hashed_row["latitude"], longitude: hashed_row["longitude"])
      else
        raise "Improperly formatted duplicate check"
      end
    end

    def self.select_order(order)
      @sites = nil
      @sites = all.order("county") if order == "county"
      @sites = all.order("state") if order == "state"
      @sites = all.order("name ASC") if order == "name_asc"
      @sites = all.order("name DESC") if order == "name_desc"
      @sites = all.order("request_date ASC") if order == "date_asc"
      @sites = all.order("request_date DESC") if order == "date_desc"
      @sites
    end
  end
end
