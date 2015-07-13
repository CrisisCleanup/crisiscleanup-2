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
# URL = "localhost:8080"

namespace :appengine_migration do
desc "imports"

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
  		appengine_import 'contact', {"organization": "legacy_organization_id"}, nil, nil, Legacy::LegacyContact
  	end

  	task :import_sites_2 => :environment do
  		appengine_import 'site', {"legacy_event_id": "legacy_event_id", "created_by": "created_by", "reported_by": "reported_by", "claimed_by": "claimed_by"}, nil, nil, Legacy::LegacySite
  	end
  	task :import_sites => :environment do
  		puts "IMPORTING Sites..."
  		create_log_file CCU_ERROR_LOGS
  		create_log_file SITE_LOGS

  		errors_count = 0
  		count = 0
  		errors = false
	  	results = get_results("site_keys", "site")
	  	results.each do |result|
	  		values_hash = JSON[result]
	  		values_hash = values_hash_for_sites values_hash
	  		event = values_hash["event"]
	  		reported_by = values_hash["reported_by"]
	  		claimed_by = values_hash["claimed_by"]

	  		values_hash.delete("event")
	  		values_hash.delete("claimed_by")
	  		values_hash.delete("reported_by")

	  		event_entity = get_postgres_entity_from_appengine_key Legacy::LegacyEvent, event_entity if event_entity
	  		reported_by_entity = get_postgres_entity_from_appengine_key Legacy::LegacyOrganization, reported_by if reported_by
	  		claimed_by_entity = get_postgres_entity_from_appengine_key Legacy::LegacyOrganization, claimed_by if claimed_by


	  	    values_hash["legacy_event_id"] = event_entity.id if event_entity
	  	    values_hash["reported_by"] = reported_by_entity.id if reported_by_entity
	  	    values_hash["claimed_by"] = claimed_by_entity.id if claimed_by_entity
	  		site = Legacy::LegacySite.new(values_hash)
	  		unless are_sites_identical? values_hash, site
	  			write_to_log_file(SITE_LOGS, "#{values_hash['appengine_key']} is not identical")
	  			errors = true
	  		end
	  		if are_there_duplicates?(Legacy::LegacySite, values_hash["appengine_key"])
	  			write_to_log_file(SITE_LOGS, "#{values_hash['appengine_key']} has duplicates")
	  			errors = true
	  		end
	  		if errors
	  			errors_count += 1
	  			puts "#{errors_count} errors"
	  		else
	  			begin
	  				site.save
			  		count +=1
			  		puts "#{count} saved"
			  	rescue => e
			  		puts "db error"
			  		puts e.message
			  		errors_count += 1
			  		puts "#{errors_count} errors"
			  		write_to_log_file(SITE_LOGS, "#{values_hash['appengine_key']} has error: #{e}")
			  	end
		  	end
	  	end	  	


  	end

  	task :events_integrity_check => :environment do
	  	run_integrity_check "event_keys", "event", Legacy::LegacyEvent
  	end

  	task :organizations_integrity_check => :environment do
  		run_integrity_check "org_keys", "organization", Legacy::LegacyOrganization
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
	result_keys.take(10).each do |key|
		begin
			count += 1
			# if count > 1
			# 	break
			# end
			puts "getting #{count}"
			
			target = "http://#{URL}/api/migration?action=get_entity_by_key&table=#{table_name}&key=#{key}"
			result = client.get_content(target)
			results << result
		rescue
			puts key
			write_to_log_file(CCU_ERROR_LOGS, "#{key} is not being returned")

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
					identical = false

				end
			else
				puts key
				puts value
				puts model_entity.attributes[key]
				puts appengine_hash["latitude"]
				puts model_entity.attributes["latitude"]
				write_to_log_file(CCU_ERROR_LOGS, "#{appengine_hash} is not identical")
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

def create_log_file filename
   	File.open(filename, 'w') do |f|  
  	end 
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
	pg_entities.each do |entity|
		appengine_entity = get_appengine_entity_from_key table, entity.appengine_key
		if are_sites_identical? appengine_entity, entity
			puts true
		else
			write_to_log_file log_file, "#{entity.appengine_key} is not identical"
			puts false
		end
	end
end

def run_integrity_check_from_pg pg_entities, table, log_file #remove log file
	puts "[#{table_name}-postgres_integrity_check]-[Information]-[Start #{table_name} integrity_check]"

	pg_entities.each do |entity|
		appengine_entity = get_appengine_entity_from_key table, entity.appengine_key
		if are_entities_identical? appengine_entity, entity
			puts true
		else
			write_to_log_file log_file, "#{entity.appengine_key} is not identical"
			puts false
		end
	end
end

def values_hash_for_sites values_hash
	values_hash["data"] = {}
	values_hash.each do |key, value|
		unless STANDARD_SITE_VALUES.include? key
			values_hash["data"][key] = values_hash[key]
			values_hash.delete(key)
		end
		if key == "work_type"
			if value.nil? or value == ""
				values_hash["work_type"] == "Other"
			end
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

def appengine_import appengine_table, relations, joins, deletions, pg_table
    puts "[#{appengine_table}-import]-[Information]-[Start #{appengine_table} import]"

    count = 0
    errors_count = 0
    errors = false

    entities = get_appengine_entities(appengine_table)
    entities.each do |entity|

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
				db_entity = get_postgres_entity_from_appengine_key Legacy::LegacyOrganization, relation if relation and key.to_s == "organization"
				db_entity = get_postgres_entity_from_appengine_key Legacy::LegacyEvent, relation if relation and key.to_s != "organization"

			    entity[value.to_s] = db_entity.id if db_entity
	    	end
	    end
	    entity = values_hash_for_sites entity if appengine_table == "site"

    	pg_entity = pg_table.new(entity)
    	unless identical_and_unique? entity, pg_entity, Legacy::LegacyEvent
    		errors_count += 1
    		puts "[#appengine_table}-import]-[Errors count: #{errors_count}]"
    		break
    	end
    	begin
    		count += 1
        	pg_entity.save
        	if joins
        		joins_hash.each do |key, value|
        			event = get_postgres_entity_from_appengine_key Legacy::LegacyEvent, value
        			puts value
        			puts "[#{appengine_table}-import]-[Error]-[Can't find event with id: #{value}]" if event.nil?
        			puts joins_hash if event.nil?
        			Legacy::LegacyOrganizationEvent.create(legacy_organization_id: pg_entity.id, legacy_event_id: event.id)
        			puts "[#{appengine_table}-import]-[Information]-[Join added for count number: #{count}]"
        		end
        	end
        	puts "[#{appengine_table}-import]-[Information]-[Success count: #{count}]"
        rescue => e
        	errors_count += 1
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
		begin
			count += 1
			if count > 500
				break
			end
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
		puts "[Error]-[Entities are not identical]-[key: #{appengine_hash[appengine_key]}]"
		success = true
	end
	if are_there_duplicates?(pg_table, appengine_hash["appengine_key"])
		puts "[Error]-[Entity has a duplicate]-[key: #{appengine_hash[appengine_key]}]"
		success = true
	end
	puts "[Success]-[Identical and Unique]" if success
	success
end
