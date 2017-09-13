module Worker
  class DashboardController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def index
      @sites = Legacy::LegacySite.where(legacy_event_id: current_user_event)
      @sites = @sites.where("user_id = ?", current_user.id)

    end

    def get_started
    end

    def incident_chooser
      referer_path = Rails.application.routes.recognize_path(URI(request.referer).path)
      referer_path[:controller] = "/" + referer_path[:controller] # To avoid adding the worker namespace
      if current_user.admin or current_user.legacy_organization.legacy_events.pluck(:id).include?(params[:id].to_i)
        current_user_event(params[:id])
        event_name = Legacy::LegacyEvent.find(params[:id]).name
        flash[:notice] = "Now viewing #{event_name}."
        referer_path[:id] = params[:id] unless referer_path[:id].blank?
      else
        flash[:alert] = "You don't have permission to view that event"
      end
      redirect_to referer_path
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
