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

		def map
			render json: @sites = Legacy::LegacySite.select("address, blurred_latitude, blurred_longitude, case_number, city, latitude, longitude, name, phone, state, status, work_type, request_date").all
		end		  
	end
end