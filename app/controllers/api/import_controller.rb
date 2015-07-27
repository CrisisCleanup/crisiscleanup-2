require 'csv'

module Api
	class ImportController < ApplicationController
		include ApplicationHelper
		before_filter :check_admin?
		def csv
			Legacy::LegacySite.import(params[:file], params[:event_id])
		end
	end
end
