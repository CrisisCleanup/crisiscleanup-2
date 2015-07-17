module Incident
  class LegacySitesController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def index
    	@sites = Legacy::LegacySite.paginate(:page => params[:page], :per_page => 50)
    end
  end
end
