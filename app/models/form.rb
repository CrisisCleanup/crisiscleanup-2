class Form < ApplicationRecord
	before_save :default_form_html
	belongs_to :legacy_event, :class_name => "Legacy::LegacyEvent"
	def self.default_html
		contents = File.open("./lib/assets/default_site_form.html", "rb").read
		 
	end

	def default_form_html
		if self.html == nil
			self.html = File.open("./lib/assets/default_site_form.html", "rb").read
		end
	end

end