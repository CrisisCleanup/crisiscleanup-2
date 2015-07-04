#TODO Auth
#TODO import_contacts
#TODO import_sites (HStore), so must do import, integrity checks differently
## Maybe put all non-standard attributes in a 'data' attribute on the app engine side
#TODO can't write a file on heroku. Write it to logs
require 'httpclient'
require 'json'

EVENT_LOGS = "import_event_error_logs.txt"
ORGANIZATION_LOGS = "import_organization_error_logs.txt"
CONTACT_LOGS = "import_contact_error_logs.txt"
SITE_LOGS = "import_site_error_logs.txt"

EVENT_INTEGRITY_CHECK_LOGS = "event_integrity_check_logs.txt"
ORGANIZATION_INTEGRITY_CHECK_LOGS = "organization_integrity_check_logs.txt"
CONTACT_INTEGRITY_CHECK_LOGS = "contact_integrity_check_logs.txt"
SITE_INTEGRITY_CHECK_LOGS = "site_integrity_check_logs.txt"

CCU_ERROR_LOGS = "CCU_error_logs.txt"

STANDARD_SITE_VALUES = ["address", "blurred_latitude", "blurred_longitude","case_number", "city", "claimed_by", "legacy_event_id", "latitude", "longitude", "name", "phone", "reported_by", "requested_at", "state", "status", "work_type", "data", "created_at", "updated_at", "appengine_key", "request_date"]

URL = "crisiscleanup.org"

# URL = "localhost:8080"
namespace :appengine_migration do
desc "imports"

	task :import_and_check_all => :environment do
		Rake::Task["appengine_migration:import_all"].invoke
		Rake::Task["appengine_migration:check_all"].invoke
		Rake::Task["appengine_migration:pg_checks"].invoke
	end

	task :import_all => :environment do
		Rake::Task["appengine_migration:import_events"].invoke
		Rake::Task["appengine_migration:import_organizations"].invoke
		Rake::Task["appengine_migration:import_contacts"].invoke
		Rake::Task["appengine_migration:import_sites"].invoke

	end

	task :check_all => :environment do
		Rake::Task["appengine_migration:events_integrity_check"].invoke
		Rake::Task["appengine_migration:organizations_integrity_check"].invoke
		Rake::Task["appengine_migration:contacts_integrity_check"].invoke
		Rake::Task["appengine_migration:sites_integrity_check"].invoke
	end

	task :pg_checks => :environment do
		Rake::Task["appengine_migration:pg_check_sites"].invoke
		Rake::Task["appengine_migration:pg_check_events"].invoke
		Rake::Task["appengine_migration:pg_check_organizations"].invoke
		Rake::Task["appengine_migration:pg_check_contacts"].invoke
	end

  	task :import_events => :environment do
  		# func with vars: event_keys, event, table(.new in unless) table(for if), log_file
  		# have functions return results as JSON
  		# Add relationships as transactions (might be different for each kind, in which case, kind is a function paramter)
  		# Add an array with which values to delete as a function argument
  		# ^ From this, extract entities to add as relationships
  		# add an arg for identicality_check. Will be different for sites
  		puts "IMPORTING EVENTS..."
  		create_log_file EVENT_LOGS
	  	results = get_results("event_keys", "event")
	  	count = 0
	  	errors_count = 0
	  	errors = false
	  	results.each do |result|
	  		values_hash = JSON[result]
	  		event =Legacy::LegacyEvent.new(values_hash)
	  		unless are_entities_identical? values_hash, event
	  			write_to_log_file(EVENT_LOGS, "#{values_hash['appengine_key']} is not identical")
	  			errors = true
	  		end
	  		if are_there_duplicates?(Legacy::LegacyEvent, values_hash["appengine_key"])
	  			write_to_log_file(EVENT_LOGS, "#{values_hash['appengine_key']} has duplicates")
	  			errors = true
	  		end
	  		if errors
	  			errors_count += 1
	  			puts "#{errors_count} errors"
	  		else
		  		begin
	  				event.save
			  		count +=1
			  		puts "#{count} saved"
			  	rescue => e
			  		write_to_log_file(ORGANIZATION_LOGS, "#{values_hash['appengine_key']} has error: #{e}")
			  	end
		  	end
	  	end
  	end


  	task :import_organizations => :environment do
  		puts "IMPORTING ORGANIZATIONS..."
  		create_log_file ORGANIZATION_LOGS
  		errors_count = 0
  		count = 0
	  	results = get_results("org_keys", "organization")
	  	results.each do |result|
	  		values_hash = JSON[result]
	  		incident_key = values_hash["incident"]
	  		incidents = values_hash["incidents"]
	  		values_hash.delete("incident")
	  		values_hash.delete("incidents")

	  		org = Legacy::LegacyOrganization.new(values_hash)
	  		unless are_entities_identical? values_hash, org
	  			write_to_log_file(ORGANIZATION_LOGS, "#{values_hash}\n#{org.attributes}")
	  			write_to_log_file(ORGANIZATION_LOGS, "#{values_hash['appengine_key']} is not identical")
	  			errors = true
	  		end
	  		if are_there_duplicates?(Legacy::LegacyOrganization, values_hash["appengine_key"])
	  			write_to_log_file(ORGANIZATION_LOGS, "#{values_hash['appengine_key']} has duplicates")
	  			errors = true
	  		end
	  		if errors
	  			errors_count += 1
	  			puts "#{errors_count} errors"
	  		else
	  			begin
	  				#TODO Transactions
	  				org.save
	  				incidents.each do |i|
	  					event = get_postgres_entity_from_appengine_key Legacy::LegacyEvent, i
	  					Legacy::LegacyOrganizationEvent.create(legacy_organization_id: org.id, legacy_event_id: event.id)
	  					puts "added join"
	  				end
	  				
			  		count +=1
			  		puts "#{count} saved"
			  	rescue => e
			  		errors_count += 1
			  		puts "#{errors_count} errors"
			  		write_to_log_file(ORGANIZATION_LOGS, "#{values_hash['appengine_key']} has error: #{e}")
			  	end
		  	end
	  	end
  	end

  	task :import_contacts => :environment do
  		puts "IMPORTING CONTACTS..."
  		create_log_file CCU_ERROR_LOGS
  		create_log_file CONTACT_LOGS
  		errors_count = 0
  		count = 0
  		errors = false
	  	results = get_results("contact_keys", "contact")
	  	results.each do |result|
	  		values_hash = JSON[result]
	  		# create as a function argument
	  		organization = values_hash["organization"]
	  		values_hash.delete("organization")
	  		org_entity = get_postgres_entity_from_appengine_key Legacy::LegacyOrganization, organization if organization
	  	    values_hash["legacy_organization_id"] = org_entity.id if org_entity
	  	    #
	  	    # Need: key, table, hash_key_name
	  		contact = Legacy::LegacyContact.new(values_hash)
	  		unless are_entities_identical? values_hash, contact
	  			write_to_log_file(CONTACT_LOGS, "#{values_hash['appengine_key']} is not identical")
	  			errors = true
	  		end
	  		if are_there_duplicates?(Legacy::LegacyContact, values_hash["appengine_key"])
	  			write_to_log_file(CONTACT_LOGS, "#{values_hash['appengine_key']} has duplicates")
	  			errors = true
	  		end
	  		if errors
	  			errors_count += 1
	  			puts "#{errors_count} errors"
	  		else
	  			begin
	  				contact.save
			  		count +=1
			  		puts "#{count} saved"
			  	rescue => e
			  		puts "db error"
			  		puts e.message
			  		errors_count += 1
			  		puts "#{errors_count} errors"
			  		write_to_log_file(CONTACT_LOGS, "#{values_hash['appengine_key']} has error: #{e}")
			  	end
		  	end
	  	end	  	
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
	  	run_integrity_check "event_keys", "event", Legacy::LegacyEvent, EVENT_INTEGRITY_CHECK_LOGS
  	end

  	task :organizations_integrity_check => :environment do
  		run_integrity_check "org_keys", "organization", Legacy::LegacyOrganization, ORGANIZATION_INTEGRITY_CHECK_LOGS
   	end

  	task :contacts_integrity_check => :environment do
  		run_integrity_check "contact_keys", "contact", Legacy::LegacyContact, CONTACT_INTEGRITY_CHECK_LOGS
  	end

  	task :sites_integrity_check => :environment do
  		run_integrity_check "site_keys", "site", Legacy::LegacySite, SITE_INTEGRITY_CHECK_LOGS
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
end
def get_results(keys, table_name)
	results = []
	proxy = ENV['HTTP_PROXY']
	client = HTTPClient.new(proxy)

	result = get_keys_from_appengine keys
	result_keys = JSON[result]
	puts result_keys.count
	# puts "Results retrieved"
	# result.delete! "[]"

	# result_keys = result.split(",")
	# #TODO use JSON
	count = 0
	# sidekiq task
	result_keys.take(100).each do |key|
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
				org = get_postgres_entity_from_appengine_key Legacy::LegacyOrganization, value
				unless org.id == model_entity.attributes[key]
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

def run_integrity_check_from_pg pg_entities, table, log_file
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

def run_integrity_check_from_pg pg_entities, table, log_file
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
	keys = []
	values_hash.each do |key, value|
		unless STANDARD_SITE_VALUES.include? key
			keys << key
		end
	end
	values_hash["data"] = {}
	keys.each do |key|
		values_hash["data"][key] = values_hash[key]
		values_hash.delete(key)
	end
	values_hash
end

def unpack_data_hash_for_integrity_check site
	site_hash = site.attributes
end

def run_integrity_check keys_type, table_name, pg_table, log_file
	results = get_keys_from_appengine keys_type
	results = JSON[results]
	count = 0
	results.each do |result|
		entity = pg_table.find_by(appengine_key: result)
	 	unless entity
	 		write_to_log_file log_file, "#{table_name} #{result} is not on postgres"
	 	end
	 	if entity
	 		count += 1
	 		puts count
	 	end
	end

end