require 'csv'

module Api
	class ImportController < ApplicationController
		include ApplicationHelper
		before_filter :check_admin?
		def csv
			Legacy::LegacySite.import(params[:file], params[:event_id], params[:duplicate_check_method], params[:handle_duplicates_method])
		end
	end
end
