class Form < ActiveRecord::Base
	belongs_to :legacy_event, :class_name => "Legacy::LegacyEvent"
	def self.default_html
		contents = File.open("./lib/assets/default_site_form.html", "rb").read
		 
	end

end