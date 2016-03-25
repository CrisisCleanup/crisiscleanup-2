require 'httpclient'
require 'json'

namespace :test_migration do
desc "imports"
	task :check_contact_organizations => :environment do
		check_contact_organizations
	end
end

def get_appengine_entity_from_key table, appengine_key
	results = []
	proxy = ENV['HTTP_PROXY']
	client = HTTPClient.new(proxy)
	target = "http://sandy-disaster-recovery.appspot.com/api/migration?action=get_entity_by_key&table=#{table}&key=#{appengine_key}"
	result = client.get_content(target)
	JSON[result]
end

def check_contact_organizations
	rescue_ids = []
	contacts_count = 0
	no_organization_count = 0
	success_count = 0
	errors_count = 0
	rescue_count = 0
	Legacy::LegacyContact.all.each do |contact|
		unless contact.appengine_key.nil?
			begin
				contacts_count += 1
				appengine_contact = get_appengine_entity_from_key("contact", contact.appengine_key)
				pg_organization = Legacy::LegacyOrganization.find_by(appengine_key: appengine_contact["organization"])
				if appengine_contact["organization"] == nil
					no_organization_count +=1
					success_count +=1
					puts "no organization: #{no_organization_count}"
					puts "success: #{success_count}"
				elsif pg_organization.id == contact.legacy_organization_id
					success_count += 1
					puts "success: #{success_count}"
				else
					error_count +=1
					puts "error: #{error_count}"
				end
			rescue Exception => e
				rescue_count +=1
				rescue_ids << contact.id
				puts "rescue: #{rescue_count}"
				puts "caught exception #{e}"
			end
		end
	end
	puts "Final contacts check"
	puts "total contacts from appengine: #{contacts_count}"
	puts "success_count: #{success_count}"
	puts "no_organization_count: #{no_organization_count}"
	puts "errors_count: #{errors_count}"
	puts "rescue_count: #{rescue_count}"
	puts "rescue_ids: #{rescue_ids}"
end