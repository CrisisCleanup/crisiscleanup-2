module Admin
  class ExportController < ApplicationController
    include ApplicationHelper
    before_action :check_admin?

    def export_kml
      @event = Legacy::LegacyEvent.find(params[:id])
      @sites = Legacy::LegacySite
                   .joins("LEFT OUTER JOIN legacy_organizations ON legacy_organizations.id = legacy_sites.claimed_by")
                   .select('legacy_sites.*, legacy_organizations.name as lg_name')
                   .where(legacy_event_id: params[:id])
      stream = render_to_string(:template=>"admin/export/export_kml.xml.builder" )
      send_data(stream, :type=>"text/xml",:filename => "#{@event.name}.kml")
    end

  end
end
