module Worker
  class DashboardController < ApplicationController
    include ApplicationHelper
    before_filter :check_user
    def index
        @requested_invitations = RequestInvitation.where(user_created: false, legacy_organization_id: current_user.legacy_organization_id).order(:name)
    end

    def incident_chooser
    	if current_user.admin or current_user.legacy_organization.legacy_events.pluck(:id).include?(params[:id].to_i)
    		current_user_event(params[:id])
    		event_name = Legacy::LegacyEvent.find(params[:id]).name
    		flash[:notice] = "Now viewing #{event_name}"
    	else
    		flash[:notice] = "You don't have permission to view that event"
    	end
    	redirect_to "/worker/dashboard"
    end
  end
end
