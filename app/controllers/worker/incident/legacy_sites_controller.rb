module Worker
  module Incident
    class LegacySitesController < ApplicationController
      include ApplicationHelper
      before_filter :check_incident_permissions

      def index
        @sites = Legacy::LegacySite.order("case_number").paginate(:page => params[:page], :per_page => 200) unless params[:order]
        @sites = Legacy::LegacySite.select_order(params[:order]).paginate(:page => params[:page], :per_page => 200) if params[:order]
        @sites = @sites.where(legacy_event_id: current_user_event).where("work_type NOT LIKE 'pda%'")
        @event_id = params[:id]
      end

      def form
        @body = 'map'
        @site = Legacy::LegacySite.new(legacy_event_id: params[:id])
        if formObj = Form.find_by(legacy_event_id: params[:id])
          @form = formObj.html
        end
        @legacy_event = Legacy::LegacyEvent.find(params[:id])
      end

      def map
        @body = 'map'
        @legacy_event = Legacy::LegacyEvent.find(params[:id])
        @site = Legacy::LegacySite.new(legacy_event_id: @legacy_event.id)
        if formObj = Form.find_by(legacy_event_id: @legacy_event.id)
          @form = formObj.html
        end
      end

      def print
        @site = Legacy::LegacySite.find(params[:site_id])

        if (@site.claimed_by)
          @claimed_by_org = Legacy::LegacyOrganization.find(@site.claimed_by)
        end

        if (@site.reported_by)
          @reported_by_org = Legacy::LegacyOrganization.find(@site.reported_by)
        end

        @address2 = @site.city
        @address2 += ", " + @site.state if @site.state
        @address2 += "  " + @site.zip_code if @site.zip_code
        @address2 += "(" + @site.county + ")" if @site.county

        render layout: false
      end

      # create
      def submit
        @site = Legacy::LegacySite.new(site_params)
        @site.data = {}
        @site.data.merge! params[:legacy_legacy_site][:data] if @site.data

        # Claimed_by toggle
        if params[:legacy_legacy_site][:claim] == "true"
          @site.claimed_by = current_user.legacy_organization_id
        end

        @site.legacy_event_id = current_user_event
        @site.reported_by = current_user.legacy_organization_id
        @form =  Form.find_by(legacy_event_id: params[:id]).html
        if @site.save
          Legacy::LegacyEvent.find(current_user_event).legacy_sites << @site
          render json: @site
        else
          if @site.errors.messages[:duplicates]
            render json: { duplicates: @site.errors.messages[:duplicates] }
          else
            render json: { errors: @site.errors.full_messages }
          end
        end

      end

      def update
        @site = Legacy::LegacySite.find(params["site_id"])
        unless @site.data
          @site.data = {}
        end
        @site.data.merge! params[:legacy_legacy_site][:data] if @site.data

        # Claimed_by toggle
        if params[:legacy_legacy_site][:claim] == "true"
          if @site.claimed_by == nil
            @site.claimed_by = current_user.legacy_organization_id
          elsif @site.claimed_by == current_user.legacy_organization_id || current_user.admin
            @site.claimed_by = nil
          end
        end

        if @site.update(site_params)
          # lol. I'm not even sure what to say here.
          render json: { updated: JSON.parse(@site.to_json(include: { legacy_organization: { only: :name } })) }
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
        @work_type_counts = Legacy::LegacySite.work_type_counts(@event.id)
        @status_counts = Legacy::LegacySite.status_counts(@event.id)
      end

      def csv
        respond_to do |format|
          format.csv { render_csv }
        end
      end

      private

      def render_csv
        set_file_headers
        set_streaming_headers

        response.status = 200

        #setting the body to an enumerator, rails will iterate this enumerator
        self.response_body = csv_lines
      end


      def set_file_headers
        event = Legacy::LegacyEvent.find(params[:id])
        file_name = "#{event.name}-#{Time.now.strftime('%F')}.csv"
        headers["Content-Type"] = "text/csv"
        headers["Content-disposition"] = "attachment; filename=\"#{file_name}\""
      end


      def set_streaming_headers
        #nginx doc: Setting this to "no" will allow unbuffered responses suitable for Comet and HTTP streaming applications
        headers['X-Accel-Buffering'] = 'no'

        headers["Cache-Control"] ||= "no-cache"
        headers.delete("Content-Length")
      end

      def csv_lines
        Enumerator.new do |y|
          y << Legacy::LegacySite.csv_header.to_s

          Legacy::LegacySite.find_in_batches({legacy_event_id: params[:id]}, 300) { |site| y << site.to_csv_row.to_s }
        end
      end

      def site_params
        params.require(:legacy_legacy_site).permit(
          :address,:blurred_latitude,:blurred_longitude,
          :case_number,:city,:claimed_by,:county,:legacy_event_id,
          :latitude,:longitude,:name,:phone1,:phone2,:reported_by,
          :request_date,:skip_duplicates,:state,:status,:work_requested,:work_type,
          :data,:zip_code)
      end
    end
  end
end
