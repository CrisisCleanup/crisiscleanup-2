module Incident
  class LegacyContactsController < ApplicationController
    include ApplicationHelper
    before_filter { |c| c.check_incident_permissions params[:id] }

    def index
    	@contacts = Legacy::LegacyContact.order("first_name").paginate(:page => params[:page])
        @event_id = params[:id]
    end

    def show
    	@contact = Legacy::LegacyContact.find(params[:contact_id])
        @event_id = params[:id]
    end
  end
end