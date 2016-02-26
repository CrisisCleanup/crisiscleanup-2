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
            flash[:notice] = "Now viewing #{event_name} from the worker dashboard."
        else
            flash[:alert] = "You don't have permission to view that event"
        end
        redirect_to "/worker/dashboard"
    end
    def redeploy_form
    end

    def redeploy_request
        @event = Legacy::LegacyEvent.find(params["Event"])
        User.where(admin:true).each do |user|
            InvitationMailer.send_redeploy_alert(@event, current_user, user.email).deliver_now
        end
        flash[:notice] = "Request to redeploy your organization for #{@event.name} sent."
        redirect_to worker_dashboard_path
    end
  end
end
