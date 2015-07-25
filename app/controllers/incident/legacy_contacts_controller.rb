module Incident
  class LegacyContactsController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def index
    	@contacts = Legacy::LegacyContact.order("name").paginate(:page => params[:page])
        @event_id = params[:id]
    end

    def show
    	@contact = Legacy::LegacyContact.find(params[:contact_id])
        @event_id = params[:event_id]
    end
  end
end