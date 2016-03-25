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
	success_count = 0
	errors_count = 0
	rescue_count = 0
	Legacy::LegacyContact.all.each do |contact|
		unless contact.appengine_key.nil?
			begin
			appengine_contact = get_appengine_entity_from_key("contact", contact.appengine_key)
			pg_organization = Legacy::LegacyOrganization.find_by(appengine_key: appengine_contact["organization"])
			if pg_organization.id == contact.legacy_organization_id
				success_count +=1
				puts "success"
			else
				error_count +=1
				puts "error"
			end
		rescue
			rescue_count +=1
			puts "rescue"
		end

		end
	end
	puts "Final contacts check"
	puts "success_count: #{success_count}"
	puts "errors_count: #{errors_count}"
	puts "rescue_count: #{rescue_count}"

end