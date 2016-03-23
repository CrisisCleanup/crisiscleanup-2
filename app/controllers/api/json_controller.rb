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
          limit = (Integer(params[:limit]) > 1000) ? 1000 : Integer(params[:limit])
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
        if site = Legacy::LegacySite.find(params[:id])
          if site.status == 'Open, unassigned' && site.claimed_by == nil
            site.claimed_by = current_user.legacy_organization_id
          end
          site.status = params[:status] if params[:status]
          site.save
          render json: { status: 'success', claimed_by: site.claimed_by, site_status: site.status }
        else
          render json: { status: 'error', msg: 'Site with id, ' + params[:id] + ', not found in our system.' }
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
            site.save
            render json: { status: 'success', claimed_by: site.claimed_by, site_status: site.status, org_name: site.claimed_by_org.name }
          elsif site.claimed_by == current_user.legacy_organization_id || current_user.admin
            site.claimed_by = nil
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

  end
end
