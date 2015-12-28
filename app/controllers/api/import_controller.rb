module Api
  class ImportController < ApplicationController
    include ApplicationHelper
    before_filter :check_admin?

    def csv
      Legacy::LegacySite.import(params)
      redirect_to worker_incident_legacy_sites_index_path(params[:event_id])
    end
  end
end
