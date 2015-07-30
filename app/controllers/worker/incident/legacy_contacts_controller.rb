module Worker
    module Incident
      class LegacyContactsController < ApplicationController
        include ApplicationHelper
        before_filter :check_incident_permissions
        
        def index
            # get all orgs with legacy_event_id: current_user_event
            # pass those ids to LegacyContact.where(legacy_organization_id: ids)
        	@contacts = Legacy::LegacyContact.order("first_name").paginate(:page => params[:page])
            @event_id = params[:id]
        end

        def show
        	@contact = Legacy::LegacyContact.find(params[:contact_id])
            @event_id = params[:id]
        end

      end
end

end