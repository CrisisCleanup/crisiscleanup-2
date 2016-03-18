require 'csv'

module Api
  module Public
    class JsonController < ApplicationController
      include ApplicationHelper

      def map
        @sites = Legacy::LegacySite.select("
          case_number,
          blurred_latitude,
          blurred_longitude,
          address,
          city,
          state,
          zip_code,
          status,
          claimed_by,
          work_type
        ").where(legacy_event_id: params[:legacy_event_id])

        @sites.each do |site|
          site.address.gsub!(/[0-9]+/, '')
        end
        render json: {"finished": true}
      end
    end
  end
end
