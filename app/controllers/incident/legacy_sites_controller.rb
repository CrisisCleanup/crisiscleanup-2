module Incident
  class LegacySitesController < ApplicationController
    layout "map_dashboard", only: [:form, :map]
    include ApplicationHelper
    before_filter { |c| c.check_incident_permissions params[:id] }

    def index
    	@sites = Legacy::LegacySite.order("case_number").paginate(:page => params[:page]) unless params[:order]
        @sites = Legacy::LegacySite.select_order(params[:order]).paginate(:page => params[:page]) if params[:order]
    end

    def map
        @legacy_event_id = params[:id]
    end

    def form
        @site = Legacy::LegacySite.new(legacy_event_id: params[:id])
        @form = Form.find_by(legacy_event_id: params[:id]).html
    end
    def submit
     
       @site = Legacy::LegacySite.new(site_params)
       @form =  Form.find_by(legacy_event_id: params[:id]).html

       if @site.save
            # figure out what to do here
            render json: @site
       else
            render json: @site.errors.full_messages
       end

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
