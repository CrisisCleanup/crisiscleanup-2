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
          id,
          name,
          address,
          city,
          state,
          phone,
          latitude,
          longitude,
          claimed_by,
          status,
          case_number,
          work_type
        ").where(legacy_event_id: params[:legacy_event_id])
      end
    end

    def update_legacy_site_status
      render json: "update status here"
    end

  end
end
