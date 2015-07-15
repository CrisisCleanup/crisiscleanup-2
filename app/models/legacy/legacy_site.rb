module Legacy
    class LegacySite < ActiveRecord::Base
        has_paper_trail
    	  
        belongs_to :legacy_event
    	  validates_presence_of :address,:blurred_latitude,:blurred_longitude,:case_number,:city,:latitude,:longitude,:name
    	

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

    end
end