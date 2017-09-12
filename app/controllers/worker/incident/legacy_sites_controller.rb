module Worker
  module Incident
    class LegacySitesController < ApplicationController
      include ApplicationHelper
      before_action :check_incident_permissions

      private

      def get_sites(endpoint, is_mysite=false)

        if params[:sort]
          store = params[:sort]
          sort = store.split("|")
        end

        if params[:filter]
          @sites = Legacy::LegacySite
            .where("legacy_event_id = ?", params[:id])
          @sites = @sites.where("user_id = ?", current_user.id) if is_mysite
          @sites = @sites.where("lower(name) LIKE ? OR lower(address) LIKE ? OR lower(case_number) LIKE ? OR lower(city) LIKE ? OR lower(county) LIKE ? OR zip_code LIKE ?",
                                "%#{params[:filter].downcase}%" , "%#{params[:filter].downcase}%",
                                "%#{params[:filter].downcase}%", "%#{params[:filter].downcase}%",
                                "%#{params[:filter].downcase}%", "%#{params[:filter].downcase}%"
          ).where("work_type NOT LIKE 'pda%'")
                      .order(params[:sort] ? "#{sort[0]} #{sort[1]}" : "case_number")
                       .paginate(:page => params["page"], :per_page => 15)

        else
          @sites = Legacy::LegacySite.where(legacy_event_id: params[:id])
             .where("legacy_event_id = ?", params[:id])
          @sites = @sites.where("user_id = ?", current_user.id) if is_mysite
          @sites = @sites.where("work_type NOT LIKE 'pda%'")
                       .order(params[:sort] ? "#{sort[0]} #{sort[1]}" : "case_number")
                       .paginate(:page => params["page"], :per_page => 15)
        end

        query = {
            "total": @sites.total_entries,
            "per_page": @sites.per_page,
            "current_page": @sites.current_page,
            "last_page": @sites.total_pages,
            "next_page_url":"/worker/incident/#{params[:id]}/#{endpoint}.json?page=#{@sites.current_page + 1}",
            "prev_page_url":"/worker/incident/#{params[:id]}/#{endpoint}.json?page=#{@sites.current_page == 1 ? 1 : @sites.current_page - 1}",
            "from": @sites.offset + 1,
            "to": @sites.offset + @sites.length,
            "data": @sites
        }
      end

      public

      def index
        @event_id = params[:id]

        if request.path_parameters[:format] == 'json'
          query = get_sites('sites', false)

        end

        respond_to do |format|
          format.html
          format.json { render json: query }
        end
      end

      def mysites
        @event_id = params[:id]

        if request.path_parameters[:format] == 'json'
          query = get_sites('mysites', true)

        end

        respond_to do |format|
            format.html
            format.json { render json: query }
        end
      end

      def form
        @body = 'map'
        @site = Legacy::LegacySite.new(legacy_event_id: params[:id])
        if formObj = Form.find_by(legacy_event_id: params[:id])
          @form = formObj.html
        end
        @legacy_event = Legacy::LegacyEvent.find(params[:id])
        render :layout => 'old_worker_dashboard'
      end

      def map
        @body = 'map'
        @legacy_event = Legacy::LegacyEvent.find(params[:id])
        @site = Legacy::LegacySite.new(legacy_event_id: @legacy_event.id)
        if formObj = Form.find_by(legacy_event_id: @legacy_event.id)
          @form = formObj.html
        end

        render :layout => 'old_worker_dashboard'
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
        data = params[:legacy_legacy_site][:data].permit!
        @site.data.merge! data if @site.data

        # Claimed_by toggle
        claim = params[:legacy_legacy_site][:claim]
        if claim == "true"
          @site.claimed_by = current_user.legacy_organization_id
          @site.user_id = current_user.id
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

      def graphs
        @org_name = Legacy::LegacyOrganization.find(current_user.legacy_organization_id).name

      end

      def graphs_site0
        @event = Legacy::LegacyEvent.find(params[:id])
        total = @event.legacy_sites
                    .where("reported_by = ?", current_user.legacy_organization_id)
                    .group_by_day(:created_at).count
        claimed = @event.legacy_sites
                           .where("claimed_by = ?", current_user.legacy_organization_id)
                           .group_by_day(:created_at).count
        closed = @event.legacy_sites
                           .where("status LIKE '%Closed%' AND claimed_by = ?", current_user.legacy_organization_id)
                           .group_by_day(:created_at).count

        r = [
          {name: "Created", data: total},
          {name: "Claimed", data: claimed},
          {name: "Completed", data: closed},
        ]

        render json: r

      end

      def graphs_site1
        @event = Legacy::LegacyEvent.find(params[:id])
        total = @event.legacy_sites
                    .where(:claimed_by => nil)
                    .group_by_day(:created_at).count
        claimed = @event.legacy_sites
                      .where.not(:claimed_by => nil)
                           .group_by_day(:created_at).count
        closed = @event.legacy_sites
                           .where("status LIKE '%Closed%'")
                           .group_by_day(:created_at).count

        r = [
          {name: "Unclaimed", data: total},
          {name: "Claimed", data: claimed},
          {name: "Completed", data: closed}
        ]

        render json: r

      end

      def graphs_site2
        @event = Legacy::LegacyEvent.find(params[:id])
        @total_day = @event.legacy_sites
                         .where("claimed_by = ?", current_user.legacy_organization_id)
                         .group(:status).count

        render json: @total_day

      end

      def graphs_site3
        @event = Legacy::LegacyEvent.find(params[:id])
        total = @event.legacy_sites
                    .where("reported_by = ?", current_user.legacy_organization_id)
                    .group_by_day(:created_at).count
        claimed = @event.legacy_sites
                           .where("claimed_by = ?", current_user.legacy_organization_id)
                           .group_by_day(:created_at).count
        closed = @event.legacy_sites
                           .where("status LIKE '%Closed%' AND claimed_by = ?", current_user.legacy_organization_id)
                           .group_by_day(:created_at).count

        r = [
          {name: "Created", data: total},
          {name: "Claimed", data: claimed},
          {name: "Completed", data: closed},
        ]

        render json: r

      end

      def graphs_site4

        org = Legacy::LegacyOrganization.find(current_user.legacy_organization_id)

        outstanding_invitations = Invitation.where(organization_id: org.id, activated: false).count
        accepted_invitations = Invitation.where(organization_id: org.id, activated: true).count

        r = [["Outstanding Invitations", outstanding_invitations],
          ["Accepted Invitations", accepted_invitations]]

        render json: r

      end


      def request_csv
        prefix = 'sites'
        bucket_name = 'S3_CSV_BUCKET'

        if params[:job_id]
          s3_helper = S3Helper.new(bucket_name)
          obj_name = "#{prefix}-#{params[:job_id]}.csv"
          if (url = s3_helper.retrieve_s3_obj_url(obj_name))
            render json: {status: 200, url: url}
          else
            render json: {status: 200, job_id: params[:job_id], message: "Still processing"}
          end
        else
          event = Legacy::LegacyEvent.find(params[:id])
          download_file_name = "#{event.name}-#{Time.now.strftime('%F')}.csv"
          job = CsvGeneratorJob.perform_later('generate_sites', prefix, download_file_name, bucket_name, params[:id])
          render json: {status: 200, job_id: job.job_id}
        end
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

      def site_params
        params.require(:legacy_legacy_site).permit(:claim,
          :address,:blurred_latitude,:blurred_longitude,
          :case_number,:city,:claimed_by,:county,:legacy_event_id,
          :latitude,:longitude,:name,:phone1,:phone2,:reported_by,
          :request_date,:skip_duplicates,:state,:status,:work_requested,:work_type,
          :data,:zip_code,:utf8,:id)
      end


    end
  end
end
