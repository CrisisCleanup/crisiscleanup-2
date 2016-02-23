require 'csv'

module Api
  module Public
    class JsonController < ApplicationController
      include ApplicationHelper

      def map
        render json: @sites = Legacy::LegacySite.select("
          data,
          case_number,
          blurred_latitude,
          blurred_longitude,
          city,
          state,
          status,
          claimed_by,
          work_type
        ").where(legacy_event_id: params[:legacy_event_id])
      end
    end
  end
end
