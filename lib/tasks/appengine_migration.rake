#TODO Auth
#TODO import_contacts
#TODO import_sites (HStore), so must do import, integrity checks differently
## Maybe put all non-standard attributes in a 'data' attribute on the app engine side
#TODO can't write a file on heroku. Write it to logs
require 'httpclient'
require 'json'

CONTACT_LOGS = "import_contact_error_logs.txt"
SITE_LOGS = "import_site_error_logs.txt"

CCU_ERROR_LOGS = "CCU_error_logs.txt"

STANDARD_SITE_VALUES = ["address", "blurred_latitude", "blurred_longitude","case_number", "city", "claimed_by", "legacy_event_id", "latitude", "longitude", "name", "phone", "reported_by", "requested_at", "state", "status", "work_type", "data", "created_at", "updated_at", "appengine_key", "request_date"]

URL = "crisiscleanup.org"

ADMIN_EMAIL = "admin@ccu.org"

# URL = "localhost:8080"

namespace :appengine_migration do
desc "imports"

	task :import_emails => :environment do
		import_appengine_emails
	end

	task :import_and_check_all => :environment do
		Rake::Task["appengine_migration:import_and_check_events"].invoke
		Rake::Task["appengine_migration:import_and_check_organizations"].invoke
		Rake::Task["appengine_migration:import_and_check_contacts"].invoke
		Rake::Task["appengine_migration:import_and_check_sites"].invoke
	end

	task :import_and_check_events => :environment do
		Rake::Task["appengine_migration:import_events"].invoke
		Rake::Task["appengine_migration:events_integrity_check"].invoke
		Rake::Task["appengine_migration:pg_check_events"].invoke
	end

	task :import_and_check_organizations => :environment do
		Rake::Task["appengine_migration:import_organizations"].invoke

		Rake::Task["appengine_migration:organizations_integrity_check"].invoke
		Rake::Task["appengine_migration:pg_check_organizations"].invoke
	end

	task :import_and_check_contacts => :environment do
		Rake::Task["appengine_migration:import_contacts"].invoke
		Rake::Task["appengine_migration:contacts_integrity_check"].invoke
		Rake::Task["appengine_migration:pg_check_contacts"].invoke
	end

		task :import_and_check_sites => :environment do
		Rake::Task["appengine_migration:import_sites"].invoke
		Rake::Task["appengine_migration:sites_integrity_check"].invoke
		Rake::Task["appengine_migration:pg_check_sites"].invoke
	end

	task :import_events => :environment do
		appengine_import 'event', nil, nil, nil, Legacy::LegacyEvent
	end


	task :import_organizations => :environment do
		appengine_import 'organization', nil, ["incidents"], ["incidents", "incident"], Legacy::LegacyOrganization
	end
  	
  	task :import_contacts => :environment do
  		appengine_import 'contact', {organization: "legacy_organization_id"}, nil, nil, Legacy::LegacyContact
  	end

  	
  	task :import_sites => :environment do
  		appengine_import 'site', {legacy_event_id: "legacy_event_id", created_by: "created_by", reported_by: "reported_by", claimed_by: "claimed_by"}, nil, nil, Legacy::LegacySite
  	end
  	
  	task :events_integrity_check => :environment do
	  	run_integrity_check "event_keys", "event", Legacy::LegacyEvent
  	end

  	task :organizations_integrity_check => :environment do
  		run_integrity_check "organization_keys", "organization", Legacy::LegacyOrganization
   	end

  	task :contacts_integrity_check => :environment do
  		run_integrity_check "contact_keys", "contact", Legacy::LegacyContact
  	end

  	task :sites_integrity_check => :environment do
  		run_integrity_check "site_keys", "site", Legacy::LegacySite
  	end

  	task :pg_check_sites => :environment do
  		run_sites_integrity_check_from_pg Legacy::LegacySite.all, "site", CCU_ERROR_LOGS
  	end

  	task :pg_check_events => :environment do
  		run_integrity_check_from_pg Legacy::LegacyEvent.all, "event", CCU_ERROR_LOGS
  	end

  	task :pg_check_contacts => :environment do
  		run_integrity_check_from_pg Legacy::LegacyContact.all, "contact", CCU_ERROR_LOGS
  	end

  	task :pg_check_organizations => :environment do
  		run_integrity_check_from_pg Legacy::LegacyOrganization.all, "organization", CCU_ERROR_LOGS
  	end 
end

def get_keys_from_appengine(keys)
	results = []
	proxy = ENV['HTTP_PROXY']
	client = HTTPClient.new(proxy)
	target = "http://#{URL}/api/migration?action=#{keys}"
	result = client.get_content(target)
	JSON[result]
end

def get_appengine_emails()
	results = []
	proxy = ENV['HTTP_PROXY']
	client = HTTPClient.new(proxy)
	target = "http://#{URL}/admin-emails-handler"
	result = client.get_content(target)
	JSON[result]
end

def get_results(keys, table_name)
	results = []
	proxy = ENV['HTTP_PROXY']
	client = HTTPClient.new(proxy)

	result_keys = get_keys_from_appengine keys
	
	puts result_keys.count
	# puts "Results retrieved"
	# result.delete! "[]"

	# result_keys = result.split(",")
	# #TODO use JSON
	count = 0
	# sidekiq task
	result_keys.each do |key|
		begin
			count += 1
			# if count > 10
			# 	break
			# end
			puts "getting #{count}"
			
			target = "http://#{URL}/api/migration?action=get_entity_by_key&table=#{table_name}&key=#{key}"
			result = client.get_content(target)
			results << result
		rescue
			puts key
		end
	end
	results
end

def are_entities_identical? appengine_hash, model_entity
	# check each value in appengine_hash against the model_entity
	# parse dates
	identical = true
	appengine_hash.each do |key, value|
		if model_entity.attributes[key] != value
			if key == "legacy_event_id"
				#TODO ?
			elsif key == "name"
				unless model_entity.attributes[key].include? value
					puts key
					return false
				end
			elsif key == "data"
				appengine_hash["data"].each do |key, value|
					v = model_entity.data[key]
					unless v.to_s == value.to_s
						puts key
						identical = false
					end
				end
			elsif key.include? "blurred"
			elsif key.include? "claimed_by" or key.include? "reported_by"
				# get entity by key, check ids against one another
				entity = get_postgres_entity_from_appengine_key Legacy::LegacyOrganization, value
				entity = get_postgres_entity_from_appengine_key Legacy::LegacyEvent, value if entity.nil?
				# set up for event
				unless entity.id == model_entity.attributes[key]
					puts key
					identical = false
				end


			elsif key.include? "date" or key.include? "activate"

				d1 = Date.parse(value.to_s)
				d2 = Date.parse(model_entity.attributes[key].to_s)
				if d1 != d2
					puts key
					identical = false
				end
			elsif key.include? "longitude" or key.include? "latitude"
				unless appengine_hash[key].round(7) == model_entity.attributes[key]
					puts key
					puts appengine_hash[key].round(6)
					puts model_entity.attributes[key]
					puts key
					identical = false

				end
			elsif key.include? "_password_hash_list"
				identical = true
			else
				puts key
				identical = false
			end
		end
	end
	identical
end

def are_sites_identical? appengine_hash, model_entity
	new_hash = values_hash_for_sites appengine_hash
	are_entities_identical? new_hash, model_entity
end

def are_there_duplicates? table, key
	!table.find_by(appengine_key: key).nil?
end


def write_to_log_file filename, line
   	File.open(filename, 'a') do |f|  
  	  f.puts line  
  	  f.puts ""
  	end 
end

def get_postgres_entity_from_appengine_key table, appengine_key
	table.find_by(appengine_key: appengine_key)
end

def get_appengine_entity_from_key table, appengine_key
	results = []
	proxy = ENV['HTTP_PROXY']
	client = HTTPClient.new(proxy)
	target = "http://#{URL}/api/migration?action=get_entity_by_key&table=#{table}&key=#{appengine_key}"
	result = client.get_content(target)
	JSON[result]
end



def run_sites_integrity_check_from_pg pg_entities, table, log_file
	puts "[#{table}-postgres_integrity_check]-[Information]-[Start #{table} integrity_check]"
	count = 0
	errors_count = 0
	pg_entities.each do |entity|
		appengine_entity = get_appengine_entity_from_key table, entity.appengine_key
		if are_sites_identical? appengine_entity, entity
			count += 1
			puts "[#{table}-postgres_integrity_check]-[Success]-[Count: #{count}]"
		else
			errors_count += 1
			# binding.pry
			puts "[#{table}-postgres_integrity_check]-[Error]-[Error count: #{errors_count}]-[PG entity: #{entity.attributes}]"
		end
	end
	puts "[#{table}-postgres_integrity_check]-[Information]-[Final success count: #{count}]"
	puts "[#{table}-postgres_integrity_check]-[Information]-[Final errors count: #{errors_count}]"
end

def run_integrity_check_from_pg pg_entities, table, log_file #remove log file
	puts "[#{table}-postgres_integrity_check]-[Information]-[Start #{table} integrity_check]"
	count = 0
	errors_count = 0
	pg_entities.each do |entity|
		appengine_entity = get_appengine_entity_from_key table, entity.appengine_key
		if table == "organization"
			# check reference
			appengine_entity.delete("incidents")
		end

		if table == "contact"
			# check reference
			appengine_entity.delete("organization")
		end
		if table == "site"
			# check references
		end
		if are_entities_identical? appengine_entity, entity
			count += 1
			# binding.pry
			puts "[#{table}-postgres_integrity_check]-[Success]-[Count: #{count}]"
		else
			errors_count += 1
			puts "[#{table}-postgres_integrity_check]-[Error]-[Error count: #{errors_count}]-[PG entity: #{entity.attributes}]"
		end
	end
	puts "[#{table}-postgres_integrity_check]-[Information]-[Final success count: #{count}]"
	puts "[#{table}-postgres_integrity_check]-[Information]-[Final errors count: #{errors_count}]"
end

def values_hash_for_sites values_hash
	values_hash["data"] = {}
	values_hash.each do |key, value|
		unless STANDARD_SITE_VALUES.include? key
			values_hash["data"][key] = values_hash[key]
			values_hash.delete(key)
		end
	end
	values_hash
end

def run_integrity_check keys_type, table_name, pg_table
    puts "[#{table_name}-integrity_check]-[Information]-[Start #{table_name} integrity_check]"
	results = get_keys_from_appengine keys_type
	count = 0
	errors_count = 0
	results.each do |result|
		entity = pg_table.find_by(appengine_key: result)
	 	unless entity
	 		errors_count += 0
	 		puts "[#{table_name}-integrity_check]-[Error]-[#{table_name} #{result} is not on postgres]"
	 	end
	 	if entity
	 		count += 1
	 		puts "[#{table_name}-integrity_check]-[Success]-[Entity number: #{count}]"
	 	end
	end
	puts "[#{table_name}-integrity_check]-[Information]-[Final success count: #{count}]"
	puts "[#{table_name}-integrity_check]-[Information]-[Final errors count: #{errors_count}]"
end

def import_appengine_emails
	emails = get_appengine_emails
	emails.each do |key, value|
		# value.each do |v|
			# get org
			# determine a user
			# remove second org from emails that don't require them (only 2 exist)
		organization = Legacy::LegacyOrganization.find_by(appengine_key: value[0])
		user = User.find_by(email: ADMIN_EMAIL)

		list = InvitationList.new(key, user, organization.id)
		if list.valid?
			if list.ready.present?  
				list.ready.each do |inv|
					InvitationMailer.send_invitation(inv, "https://crisiscleanup.org").deliver_now
	                RequestInvitation.invited!(inv.invitee_email)
				end
			end
	    end  
		# end
	end

end
def appengine_import appengine_table, relations, joins, deletions, pg_table
    puts "[#{appengine_table}-import]-[Information]-[Start #{appengine_table} import]"

    count = 0
    errors_count = 0
    errors = false

    entities = get_appengine_entities(appengine_table)
    entities.each do |entity|
    	# sleep for heroku throttling

    	sleep 0.1
    	#make these separate functions
    	#entity = add_joins entity if joins, etc
    	if joins
    		
	    	joins_hash = {}
	    	joins.each do |join|
	    		joins_hash[join] = entity[join]
	    	end
	    end

	    if deletions
	    	deletions.each do |deletion|
	    		entity.delete(deletion)
	    	end
	    end
	    if relations
	    	relations.each do |key, value|
				relation = entity[key.to_s]
				entity.delete(key.to_s)
				# db_table = Legacy::LegacyOrganization if key == "organization"
				# db_table = Legacy::LegacyEvent if key != "organization"
				db_entity = get_postgres_entity_from_appengine_key Legacy::LegacyOrganization, relation if relation and key.to_s != "legacy_event_id"
				db_entity = get_postgres_entity_from_appengine_key Legacy::LegacyEvent, relation if relation and key.to_s == "legacy_event_id"
			    entity[value.to_s] = db_entity.id if db_entity
	

	    	end
	    end
	    entity = values_hash_for_sites entity if appengine_table == "site"

    	pg_entity = pg_table.new(entity)
    	if appengine_table == "site"
	    	unless identical_and_unique? entity, pg_entity, Legacy::LegacySite
	    		errors_count += 1
	    		puts "[#appengine_table}-import]-[Errors count: #{errors_count}]"
	    		next
	    	end
	    else
	    	unless identical_and_unique? entity, pg_entity, Legacy::LegacyEvent
	    		errors_count += 1
	    		puts "[#appengine_table}-import]-[Errors count: #{errors_count}]"
	    		next
	    	end
	    end
    	begin
    		pg_entity.created_at = DateTime.now if pg_entity.created_at.nil?
    		pg_entity.updated_at = DateTime.now if pg_entity.updated_at.nil?


    		if pg_table == Legacy::LegacyOrganization and Legacy::LegacyOrganization.where(name: pg_entity.name).count > 0
    			pg_entity.name = pg_entity.name + "_#{Random.rand(100)}"
    		end

    		if pg_table == Legacy::LegacyOrganization
    			pg_entity.accepted_terms = true
    		end

        	pg_entity.save

        	unless pg_entity.valid?
        		binding.pry
        		raise "entity invalid + #{pg_entity.to_json}"
        		# TODO
        		# if error is name is already taken, get existing entity and set that as the pg entity
        	end
        	if joins
        		joins_hash.each do |key, value|
        			if value.length == 1
	        			event = get_postgres_entity_from_appengine_key Legacy::LegacyEvent, value
	        			puts "[#{appengine_table}-import]-[Error]-[Can't find event with id: #{value}]" if event.nil?
	        			puts joins_hash if event.nil?
	        			# unless pg_entity.valid? 
		        		# 	binding.pry
		        		# end
		        		# if pg_entity.name.include? "Knights"
		        		# 	binding.pry
		        		# end
	        			Legacy::LegacyOrganizationEvent.create(legacy_organization_id: pg_entity.id, legacy_event_id: event.id)
	        			puts "[#{appengine_table}-import]-[Information]-[Join added for count number: #{count}]-[organization: #{pg_entity.name}]"
	        		else
	        			value.each do |val|
		        			event = get_postgres_entity_from_appengine_key Legacy::LegacyEvent, val
		        			puts "[#{appengine_table}-import]-[Error]-[Can't find event with id: #{val}]" if event.nil?
		        			puts joins_hash if event.nil?
		        			# unless pg_entity.valid? 
			        		# 	binding.pry
			        		# end
			        		# count += 1
			        		# if pg_entity.name.include? "Knights"
			        		# 	binding.pry
			        		# end
		        			Legacy::LegacyOrganizationEvent.create(legacy_organization_id: pg_entity.id, legacy_event_id: event.id)
		        			puts "[#{appengine_table}-import]-[Information]-[Join added for count number: #{count}]-[organization: #{pg_entity.name}]"
	        			end
	        		end
        		end
        	end

        	count += 1
	    	unless count == pg_table.count
	    		# binding.pry
	    	end
        	puts "[#{appengine_table}-import]-[Information]-[Success count: #{count}]"
        rescue => e
        	errors_count += 1
        	# binding.pry
        	puts "[#{appengine_table}-import]-[Error]-[Database Error Message: #{e}]"
        	puts "[#{appengine_table}-import]-[Error]-[App engine key: #{entity['appengine_key']}]"
            puts "[#{appengine_table}-import]-[Errors count: #{errors_count}]"

    	end
    end    
    puts "[#{appengine_table}-import]-[Information]-[Final success count: #{count}]"
    puts "[#{appengine_table}-import]-[Information]-[Final errors count: #{errors_count}]"
end

def get_appengine_entities(table_name)
	results = []
	proxy = ENV['HTTP_PROXY']
	client = HTTPClient.new(proxy)

	result_keys = get_keys_from_appengine "#{table_name}_keys"
	puts "[#{table_name}-import]-[Information]-[Total entities: #{result_keys.count}]"
	count = 0
	errors_count = 0
	result_keys.each do |key|
		# if count == 10
		# 	return results
		# end
		begin
			count += 1
			# if count > 10
			# 	break
			# end
			puts "[#{table_name}-import]-[Information]-[getting #{count}]"
			target = "http://#{URL}/api/migration?action=get_entity_by_key&table=#{table_name}&key=#{key}"
			result = client.get_content(target)
			results << JSON[result]
		rescue
			errors_count += 1
			puts "[#{table_name}-import]-[Error]-[Could not download key: #{key}]"
			puts "[#{table_name}-import]-[Error]-[Errors count: #{errors_count}]"


		end
	end
	puts "[#{table_name}-import]-[Information]-[Get entities success count: #{count}]"
	puts "[#{table_name}-import]-[Information]-[Get entities errors count: #{errors_count}]"
	results
end

def identical_and_unique? appengine_hash, model_entity, pg_table
	success = true
	unless are_entities_identical? appengine_hash, model_entity
		puts "[Error]-[Entities are not identical]-[key: #{appengine_hash['appengine_key']}]"
		success = false
	end
	if are_there_duplicates?(pg_table, appengine_hash["appengine_key"])
		puts "[Error]-[Entity has a duplicate]-[key: #{appengine_hash['appengine_key']}]"
		success = false
	end
	puts "[Success]-[Identical and Unique]" if success
	success
end
