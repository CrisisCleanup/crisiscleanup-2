module Worker
  module Incident
    class LegacyOrganizationsController < ApplicationController
      include ApplicationHelper
      before_filter :check_incident_permissions

      def index
        # search legacy_organization_event for legacy_organization_id: current_user_event
        # pass those ids to LegacyOrg.find(ids)
        org_ids = Legacy::LegacyOrganizationEvent.select("legacy_organization_id").where(legacy_event_id: current_user_event)
        @orgs = Legacy::LegacyOrganization.order("name").where(id: org_ids).where(org_verified: true).paginate(:page => params[:page])
        @event_id = current_user_event
      end

      def show
        @organization = Legacy::LegacyOrganization.find(params[:org_id])
        if @organization 
          @user_is_member = (params[:org_id].to_i == current_user.legacy_organization_id)
          if request.post? and @user_is_member
            if params[:caller_access]
              @organization.allow_caller_access = true
            else 
              @organization.allow_caller_access = false
            end            
            @organization.save!
            @event_id = current_user_event
            return redirect_to :back
          end
        end       
        @event_id = current_user_event
      end
      
    end
  end
end
