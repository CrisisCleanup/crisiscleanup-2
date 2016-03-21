# require 'csv'
module Api
  module Public
    class JsonController < ApplicationController
      include ApplicationHelper

      def map
        begin
          limit = (Integer(params[:limit]) > 500) ? 500 : Integer(params[:limit])
          page = (Integer(params[:page]) < 1) ? 1 : Integer(params[:page])
        rescue ArgumentError
          return
        end
        offset = (page - 1) * limit + 1
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
        ").where(legacy_event_id: params[:event_id])
          .limit(limit)
          .offset(offset)

        # @sites.each do |site|
        #   site.address.gsub!(/[0-9]+/, '')
        # end
        render "api/public/json/map"
      end

      def siteCount
        render json: Legacy::LegacySite.where({legacy_event_id: params[:event_id]}).count
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
