require 'csv'

module Api
	class JsonController < ApplicationController
		include ApplicationHelper
		
		def map
			render json: @sites = Legacy::LegacySite.select("latitude, longitude, status, work_type, city, state, id").where(legacy_event_id: params[:legacy_event_id])
		end
	end
end
