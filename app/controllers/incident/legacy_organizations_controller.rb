module Incident
  class LegacyOrganizationsController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def index
    	@orgs = Legacy::LegacyOrganization.paginate(:page => params[:page], :per_page => 50)
    end

    def show
    	@organization = Legacy::LegacyOrganization.find(params[:org_id])
    end
  end
end