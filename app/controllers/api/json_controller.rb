require 'csv'

module Api
  class JsonController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def map
      if params["pin"]
        render json: @sites = Legacy::LegacySite.find(params["pin"])
      else
        render json: @sites = Legacy::LegacySite.select("
          legacy_sites.*,
          legacy_organizations.name as org_name
        ").where(legacy_event_id: params[:legacy_event_id])
          .joins("LEFT OUTER JOIN legacy_organizations ON legacy_organizations.id = legacy_sites.claimed_by")
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
          render json: { status: 'error', msg: 'Site with id, ' + params[:id] + ', not found in our syste.' }
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
            render json: { status: 'success', claimed_by: site.claimed_by, site_status: site.status }
          elsif site.claimed_by == current_user.legacy_organization_id
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
