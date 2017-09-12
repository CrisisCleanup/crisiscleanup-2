module Api
	class PdfController < ApplicationController
		include ApplicationHelper
		before_action :check_admin?
		def site
			render json: "[]"
		end
	end
end
