module Worker
  module Incident
    class LegacyEventsController < ApplicationController
      include ApplicationHelper
      before_filter :check_incident_permissions

      def download_sites
        @event = Legacy::LegacyEvent.find(params[:id])

        send_data @event.sites_to_csv, filename: "#{@event.name}-#{Time.now.strftime('%F')}.csv"
      end

    end
  end
end
