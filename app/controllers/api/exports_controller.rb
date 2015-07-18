require 'csv'

module Api
	class ExportsController < ApplicationController
		include ApplicationHelper

		def sites
			@sites = Legacy::LegacySite.all
			# respond_to do |format|
			# 	format.csv { send_data @sites.to_csv }
			# end
			send_data @sites.to_csv
			binding.pry
		end
	  
	end
end