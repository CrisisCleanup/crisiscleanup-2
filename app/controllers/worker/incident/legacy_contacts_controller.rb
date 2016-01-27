module Worker
    module Incident
      class LegacyContactsController < ApplicationController
        include ApplicationHelper
        before_filter :check_incident_permissions
        
        def index
            org_ids = Legacy::LegacyOrganizationEvent.select("id").where(legacy_event_id: current_user_event)
        	@contacts = Legacy::LegacyContact.order("first_name").where(legacy_organization_id: org_ids).paginate(:page => params[:page])
            @event_id = params[:id]
            @users = User.where(legacy_organization_id: current_user.legacy_organization_id)
        end

        def show
        	@contact = Legacy::LegacyContact.find(params[:contact_id])
            @event_id = params[:id]
        end

      end
end

end