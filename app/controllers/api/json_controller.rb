require 'csv'

module Api
	class JsonController < ApplicationController
		include ApplicationHelper
		
		def map
			if params["pin"]
				render json: @sites = Legacy::LegacySite.find(params["pin"])
			else
				render json: @sites = Legacy::LegacySite.select("latitude, longitude, status, work_type, city, state, id").where(legacy_event_id: params[:legacy_event_id])
			end
		end
	end
end
