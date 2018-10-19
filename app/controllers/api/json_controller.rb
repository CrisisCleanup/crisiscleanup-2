# require 'csv'

module Api
  class JsonController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def map
      if params["pin"]
        @sites = Legacy::LegacySite.find(params["pin"])
      else
        begin
          limit = (Integer(params[:limit]) > 1000) ? 15000 : Integer(params[:limit])
          page = (Integer(params[:page]) < 1) ? 1 : Integer(params[:page])
        rescue ArgumentError
          return
        end
        offset = (page - 1) * limit
        @sites = Legacy::LegacySite.select("
          legacy_sites.id,
          legacy_sites.latitude,
          legacy_sites.longitude,
          legacy_sites.work_type,
          legacy_sites.status,
          legacy_sites.claimed_by,
          legacy_sites.case_number,
          legacy_sites.name,
          legacy_sites.address,
          legacy_sites.city,
          legacy_sites.state,
          legacy_sites.zip_code
        ").where(legacy_event_id: params[:event_id])
          .limit(limit)
          .offset(offset)
          .order(:id)
        render :json => @sites.to_json()
      end
    end

    def site_history

      if site = Legacy::LegacySite.find(params[:id])
        versions = site.versions
        m = Hash.new
        versions.reverse.each do |version|
          if !m.key?(version.user.name)
            m[version.user.name] = {
                versions: [],
                user_info: version.user
            }
          end

          v = { version_info: version }
          current_version = version.next
          previous_version = version
          if current_version != nil && previous_version != nil
            previous_site = previous_version.reify
            current_site = current_version.reify

            if ((!previous_site.respond_to?(:user_id) || previous_site.user_id.nil?) && !current_site.user_id.nil?)
              v[:claimed] = true
            end
          else
            # this is the latest version
            if ((!previous_site.respond_to?(:user_id) || previous_site.user_id.nil?) && !site.user_id.nil?)
              v[:claimed] = true
            end
          end

          m[version.user.name][:versions] << v
        end

        resp = {history: m}
        if site.user_id?
          r = User.select("users.name as u_name,
                           users.email as u_email,
                           users.mobile as u_mobile,
                           legacy_organizations.name as lg_name, legacy_organizations.id as lg_id")
                  .joins(:legacy_organization).where("users.id= ?", site.user_id)
          resp[:claimed_by_user] = r.first
        else
          resp[:claimed_by_user] = nil
        end

        render json: resp
      end

    end

    def site
      if @site = Legacy::LegacySite.select("
          legacy_sites.*,
          legacy_organizations.name as org_name
        ").where("legacy_sites.id = ?", params[:id].to_i)
          .joins("LEFT OUTER JOIN legacy_organizations ON legacy_organizations.id = legacy_sites.claimed_by")
          .take

        render json: @site
      else
        render json: { status: 'error', msg: 'Site with id, ' + params[:id] + ', not found in our system.' }
      end
    end

    def update_legacy_site_status
      if params[:id]
        # Guard status types
        status = [ "Open, unassigned", "Open, assigned",
          "Open, partially completed", "Open, needs follow-up",
          "Closed, completed", "Closed, incomplete",
          "Closed, out of scope", "Closed, done by others",
          "Closed, no help wanted", "Closed, rejected",
          "Closed, duplicate"]
        if not status.include?(params[:status])
          render json: { status: 'error', msg: 'Not a site status type' }, status: 400
        else

          if site = Legacy::LegacySite.find(params[:id])
            if site.status == 'Open, unassigned' && site.claimed_by == nil
              site.claimed_by = current_user.legacy_organization_id
              site.user_id = current_user.id
            end
            site.status = params[:status] if params[:status]
            site.save
            render json: { status: 'success', claimed_by: site.claimed_by, site_status: site.status }
          else
            render json: { status: 'error', msg: 'Site with id, ' + params[:id] + ', not found in our system.' }
          end
        end
      else
        render json: { status: 'error', msg: 'Site id is required.' }
      end
    end

    # claim/unclaim toggle
    # TODO: clean this up
    def claim_legacy_site
      if params[:id]
        if site = Legacy::LegacySite.find(params[:id])
          if site.claimed_by == nil
            site.claimed_by = current_user.legacy_organization_id
            site.user = current_user
            site.save
            render json: { status: 'success', claimed_by: site.claimed_by, site_status: site.status, org_name: site.claimed_by_org.name }
          elsif site.claimed_by == current_user.legacy_organization_id || current_user.admin
            site.claimed_by = nil
            site.user = nil
            site.save
            render json: { status: 'success', claimed_by: site.claimed_by, site_status: site.status }
          else
            render json: { status: 'error', msg: 'You do not have permission to do that.' }
          end
        end
      else
        render json: { status: 'error', msg: 'Site id is required.' }
      end
    end
    
    def incidents
      render json: { incidents: Legacy::LegacyEvent.select('id,name') }
    end
    
    def move_worksite_to_incident
      
      worksiteId = params[:worksiteId]
      incidentId = params[:incidentId]
      
      if site = Legacy::LegacySite.find(worksiteId)
        if incident = Legacy::LegacyEvent.find(incidentId)
          site.legacy_event_id = incidentId
          site.case_number = nil
          site.claimed_by = nil
          site.user_id = nil
          site.save!
        end
      end
      
      render json: { status: 'success', msg: 'Site moved to incident.' }
    end
    
    def relocate_worksite_pin
      
      worksiteId = params[:worksiteId]
      longitude = params[:longitude]
      latitude = params[:latitude]
      zoomLevel = params[:zoomLevel]
      
      if zoomLevel < 20
        render json: { status: 'error', msg: 'Zoom level must be 20 or greater.' }
      end
      
      if site = Legacy::LegacySite.find(worksiteId)
        site.latitude = latitude
        site.longitude = longitude
        site.blurred_latitude = nil
        site.blurred_longitude = nil
        site.save!
      end
      
      render json: { status: 'success', msg: 'Worksite pin relocated.' }
    end

  end
end
