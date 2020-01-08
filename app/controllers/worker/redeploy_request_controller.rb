module Worker

  class RedeployRequestController < ApplicationController
    include ApplicationHelper

    def new
      @redeploy_request = RedeployRequest.new
    end

    def create
      @redeploy_request = RedeployRequest.new(redeploy_request_params)
      @event = Legacy::LegacyEvent.find(redeploy_request_params[:legacy_event_id])
      @redeploy_request.legacy_organization = current_user.legacy_organization
      @redeploy_request.legacy_event = @event
      # Check if the user's organization is already re-deployed to the requested incident.
      if current_user.legacy_organization.legacy_events.pluck(:id).include?(@event.id)
        flash[:alert] = "Your organization already has access to the #{@redeploy_request.legacy_event.name} incident. You do not need to redeploy. Please use the drop-down to the right to select the incident you want to view."
      else
        @redeploy_request.save!
        User.where(admin:true).each do |user|
          InvitationMailer.send_redeploy_alert(@redeploy_request, current_user, user.email, request.remote_ip).deliver_now
        end
        flash[:notice] = "Request to redeploy your organization for #{@redeploy_request.legacy_event.name} sent."
      end
      redirect_to worker_dashboard_path
    end

    def accept
      if !current_user.present? or !current_user.admin?
        redirect_to '/login'
      end
      redeploy_request = RedeployRequest.where(token:params[:token]).first
      redeploy_request.accepted = true
      redeploy_request.accepted_by = current_user.id
      event = redeploy_request.legacy_event
      org = redeploy_request.legacy_organization
      org.legacy_events << event
      org.save!
      redeploy_request.save!
      flash[:notice] = "You accepted #{org.name}'s request to redeploy to #{event.name}."
      redirect_to '/dashboard'
    end

    private
    def redeploy_request_params
      params.permit(
        :legacy_event_id
      )
    end

  end

end
