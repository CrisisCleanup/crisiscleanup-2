module ApiHelper
	STANDARD_SITE_VALUES = ["address", "blurred_latitude", "blurred_longitude","case_number", "city", "claimed_by", "legacy_event_id", "latitude", "longitude", "name", "phone", "reported_by", "requested_at", "state", "status", "work_type", "data", "created_at", "updated_at", "appengine_key", "request_date"]
	def flat_attributes_to_hstore_hash flat_attributes
		data_hash = {}
		flat_attributes.each do |key, value|
			unless STANDARD_SITE_VALUES.include? key
				data_hash[key] = value
				flat_attributes.delete(key)
			end
		end
		flat_attributes['data'] = data_hash
		flat_attributes
	end

	def hstore_hash_to_flat_attributes db_entity
		db_entity['data'].each do |key, value|
			db_entity[key] = value
		end
		db_entity.delete('data')
		db_entity
	end
end
