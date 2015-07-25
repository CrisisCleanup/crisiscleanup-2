module Incident
  class LegacyOrganizationsController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def index
    	@orgs = Legacy::LegacyOrganization.order("name").paginate(:page => params[:page])
    	@event_id = params[:id]
    end

    def show
    	@organization = Legacy::LegacyOrganization.find(params[:org_id])
    	@event_id = params[:event_id]
    end
  end
end