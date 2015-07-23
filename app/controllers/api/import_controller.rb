require 'csv'

module Api
	class ImportController < ApplicationController
		include ApplicationHelper
		before_filter :check_admin?

		def csv
			binding.pry
		end
	end
end
