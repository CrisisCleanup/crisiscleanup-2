# require 'csv'
module Api
  module Public
    class JsonController < ApplicationController
      include ApplicationHelper

      def map
        @sites = Legacy::LegacySite.select("
          case_number,
          blurred_latitude,
          blurred_longitude,
          city,
          state,
          zip_code,
          status,
          claimed_by,
          work_type
        ").where(legacy_event_id: params[:legacy_event_id])

        # @sites.each do |site|
        #   site.address.gsub!(/[0-9]+/, '')
        # end
        render "api/public/json/map"
      end

      def contacts
        # @contacts = Legacy::LegacyContact.select("
        #   organizational_title,
        #   legacy_organization_id,
        #   is_primary,
        #   phone,
        #   appengine_key,
        #   created_at,
        #   updated_at,
        #   title
        # ").where(is_primary: true)

        # render json: @contacts
        @organizations = Legacy::LegacyOrganization.select("
          city,
          is_active,
          created_at,
          updated_at,
          is_active,
          is_admin,
          state,
          timestamp_login,
          timestamp_signup
          ").limit(200)
        render json: @organizations
      end
    end
  end
end
