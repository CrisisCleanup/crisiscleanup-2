module Worker
  module Incident
    class LegacySitesController < ApplicationController
      include ApplicationHelper
      before_filter :check_incident_permissions

      def index
        @sites = Legacy::LegacySite.order("case_number").paginate(:page => params[:page]) unless params[:order]
        @sites = Legacy::LegacySite.select_order(params[:order]).paginate(:page => params[:page]) if params[:order]
        @sites = @sites.where(legacy_event_id: current_user_event)
        @event_id = params[:id]
      end

      def form
        @body = 'map'
        @site = Legacy::LegacySite.new(legacy_event_id: params[:id])
        @form = Form.find_by(legacy_event_id: params[:id]).html
        @legacy_event = Legacy::LegacyEvent.find(params[:id])
      end

      def map
        @body = 'map'
        @legacy_event = Legacy::LegacyEvent.find(params[:id])
        @site = Legacy::LegacySite.new(legacy_event_id: @legacy_event.id)
        @form = Form.find_by(legacy_event_id: @legacy_event.id).html
      end

      def submit
        @site = Legacy::LegacySite.new(site_params)
        @site.data = params[:legacy_legacy_site][:data]

        @site.legacy_event_id = current_user_event
        @form =  Form.find_by(legacy_event_id: params[:id]).html

        if @site.save
          Legacy::LegacyEvent.find(current_user_event).legacy_sites << @site
          render json: @site
        else
          render json: @site.errors.full_messages
        end

      end

      def update
        @site = Legacy::LegacySite.find(params["site_id"])
        @site.data = params[:legacy_legacy_site][:data]
        @form =  Form.find_by(legacy_event_id: params[:id]).html
        if @site.update(site_params)
          render json: {updated:@site}
        else
          render json: @site.errors.full_messages
        end
      end

      def edit
        @body = 'map'
        @site = Legacy::LegacySite.find(params[:site_id])
        @legacy_event = Legacy::LegacyEvent.find(params[:id])
        @form = Form.find_by(legacy_event_id: params[:id]).html
        @site_json = JSON[@site.attributes]
      end

      def stats
        @event = Legacy::LegacyEvent.find(params[:id])
        org_ids = Legacy::LegacyOrganizationEvent.where(legacy_event_id: @event.id)
        @orgs = Legacy::LegacyOrganization.where(id: org_ids)
        @work_type_counts = Legacy::LegacySite.work_type_counts(@event.id)
        @status_counts = Legacy::LegacySite.status_counts(@event.id)
      end

      private
      def site_params
        params.require(:legacy_legacy_site).permit(
          :address,:blurred_latitude,:blurred_longitude,
          :case_number,:city,:claimed_by,:legacy_event_id,
          :latitude,:longitude,:name,:phone,:reported_by,
          :requested_at,:state,:status,:work_type,:data,:zip_code)
      end
    end
  end
end
