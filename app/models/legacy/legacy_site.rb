module Legacy
    class LegacySite < ActiveRecord::Base
        PERSONAL_FIELDS = ["id", "address", "case_number", "latitude", "longitude", "claimed_by", "phone", "name", "created_at", "updated_at", "appengine_key"]
        self.per_page = 500
        has_paper_trail
        geocoded_by :full_street_address 
        before_validation :geocode, if: ->(obj){ obj.latitude.nil? or obj.longitude.nil? or obj.address_changed? }
        before_validation :create_blurred_geocoordinates
        belongs_to :legacy_event
    	validates_presence_of :address,:blurred_latitude,:blurred_longitude,:case_number,:city,:latitude,:longitude,:name
    	
        def full_street_address
            "#{self.address}, #{self.city}, #{self.state}"
        end

        def create_blurred_geocoordinates
            self.blurred_latitude = self.latitude + rand(-0.0187..0.0187)
            self.blurred_longitude = self.longitude + rand(-0.0187..0.0187)
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
            binding.pry
            csv << get_column_names(params)
            all.each do |site|
                # make a site hash with 'data' extracted
                # replace site.attributes.below
              csv << site.attributes.values_at(*column_names)
            end
          end
        end

        def self.get_column_names(params)
            @c = column_names
            if params[:params][:type] == "deidentified"
                PERSONAL_FIELDS.each do |field|
                    @c.delete(field)
                end
            end
            @c
        end
    end
end