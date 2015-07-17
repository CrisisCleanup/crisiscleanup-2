module Incident
  class LegacyContactsController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def index
    	@contacts = Legacy::LegacyContact.paginate(:page => params[:page], :per_page => 50)
        @event_id = params[:id]
    end

    def show
    	@contact = Legacy::LegacyContact.find(params[:contact_id])
        @event_id = params[:event_id]
    end
  end
end