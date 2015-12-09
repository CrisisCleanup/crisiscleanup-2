module Legacy
    class LegacySite < ActiveRecord::Base
        # default_scope { order('case_number') }
        require 'csv'

        STANDARD_SITE_VALUES = ["address", "blurred_latitude", "blurred_longitude","case_number", "city", "claimed_by", "legacy_event_id", "latitude", "longitude", "name", "phone", "reported_by", "requested_at", "state", "status", "work_type", "data", "created_at", "updated_at", "appengine_key", "request_date"]
        PERSONAL_FIELDS = ["id", "address", "case_number", "latitude", "longitude", "claimed_by", "phone", "name", "created_at", "updated_at", "appengine_key"]
        CSV_HEADER_FIELDS = ["request_date", "case_number", "name", "address", "phone", "latitude", "longitude", "city", "state", "status", "work_type", "claimed_by", "reported_by" ]
        self.per_page = 500
        has_paper_trail
        geocoded_by :full_street_address 
        validates_presence_of :address,:blurred_latitude,:blurred_longitude,:case_number,:city,:latitude,:longitude,:name, :work_type, :status
        before_validation :geocode, if: ->(obj){ obj.latitude.nil? or obj.longitude.nil? or obj.address_changed? }
        before_validation :create_blurred_geocoordinates
        before_validation :add_case_number
        belongs_to :legacy_event
    	
    	
        def full_street_address
            "#{self.address}, #{self.city}, #{self.state}"
        end

        def add_case_number
            if self.legacy_event_id
                count = Legacy::LegacySite.where(legacy_event_id: self.legacy_event_id).count
                event_case_label = Legacy::LegacyEvent.find(self.legacy_event_id).case_label
                self.case_number = "#{event_case_label}#{count + 1}"
            end
        end

        def create_blurred_geocoordinates
            self.blurred_latitude = self.latitude + rand(-0.0187..0.0187) if self.latitude
            self.blurred_longitude = self.longitude + rand(-0.0187..0.0187) if self.longitude
        end

        def claimed_by_org
        	LegacyOrganization.find(self.claimed_by)
        end
        def reported_by_org
        	LegacyOrganization.find(self.reported_by)
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

        def self.get_column_names(params)
            @c = CSV_HEADER_FIELDS
            if params[:params][:type] == "deidentified"
                PERSONAL_FIELDS.each do |field|
                    @c.delete(field)
                end
            end
            all.each do |site|
                if site.data
                    site.data.each do |key, value|
                        @c << key
                    end
                end
            end
            @c.delete("name_metaphone")
            @c.delete("address_metaphone")
            @c.delete("city_metaphone")
            @c.flatten.uniq
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

        def self.hash_to_site hash_attributes, event_id
            data = {}
            hash_attributes.each do |key, value|
                unless STANDARD_SITE_VALUES.include? key
                    data[key] = value
                    hash_attributes.delete(key)
                end
            end

            ### TODO delete these when using real ids
            # hash_attributes.delete("reported_by")
            # hash_attributes.delete("claimed_by")
            #########################################

            hash_attributes['data'] = data
            hash_attributes['legacy_event_id'] = event_id
            hash_attributes
        end
        def self.import(file, event_id, duplicate_check=nil, duplicate_method=nil)
            CSV.foreach(file.path, headers: true) do |row|
                hashed_row = row.to_hash
                if duplicate_check
                    check_update(hashed_row, duplicate_check, duplicate_method, event_id)
                else
                    create_from_row(hashed_row, event_id)
                end
            end
        end

        def self.check_update(hashed_row, duplicate_check, duplicate_method, event_id)
            if search_duplicate(hashed_row, duplicate_check)
                update_from_row(hashed_row, duplicate_method, duplicate_method)
            else
                create_from_row(hashed_row, event_id)
            end
        end

        def self.create_from_row(hashed_row, event_id)
            Legacy::LegacySite.create! hash_to_site(hashed_row, event_id)
        end

        def self.update_from_row(hashed_row, duplicate_check, duplicate_method)
            if duplicate_method == "references"
                @site = search_duplicate(hashed_row, duplicate_check)
                @site.update(claimed_by: hashed_row[:claimed_by], reported_by: hashed_row[:reported_by])
            elsif duplicate_method == "references_and_work_type"
                @site = search_duplicate(hashed_row, duplicate_check)
                @site.update(work_type: hashed_row["work_type"], claimed_by: hashed_row[:claimed_by], reported_by: hashed_row[:reported_by])
            else
                @site = search_duplicate(hashed_row, duplicate_check)
                @site.update(hash_to_site(hashed_row, event_id))
            end

        end

        def self.search_duplicate(hashed_row, duplicate_check)
            @site = nil
            if duplicate_check == "name_lat_lng"
                @site = Legacy::LegacySite.find_by(name: hashed_row["name"], latitude: hashed_row["latitude"], longitude: hashed_row["longitude"])
            elsif duplicate_check == "lat_lng"
                @site = Legacy::LegacySite.find_by(latitude: hashed_row["latitude"], longitude: hashed_row["longitude"])
            else
                raise "Improperly formatted duplicate check"
            end
            @site
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