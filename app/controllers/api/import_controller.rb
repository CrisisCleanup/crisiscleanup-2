module Api
  class ImportController < ApplicationController
    include ApplicationHelper
    before_action :check_admin?

    def csv
      Legacy::LegacySite.import(params[:file], params[:duplicate_check_method], params[:handle_duplicates_method], params[:event_id])
      redirect_to worker_incident_legacy_sites_index_path(params[:event_id])
    end
  end
end
