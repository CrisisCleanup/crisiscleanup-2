module Worker
    module Incident
      class LegacyContactsController < ApplicationController
        include ApplicationHelper
        before_filter :check_incident_permissions
        before_filter :assign_class
        def index
        	@contacts = Legacy::LegacyContact.order("first_name").paginate(:page => params[:page])
            @event_id = params[:id]
        end

        def show
        	@contact = Legacy::LegacyContact.find(params[:contact_id])
            @event_id = params[:id]
        end
        def assign_class
            @body = 'incident'
        end
      end
end

end