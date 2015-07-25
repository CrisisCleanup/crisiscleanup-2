module Incident
  class LegacySitesController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def index
    	@sites = Legacy::LegacySite.order("case_number").paginate(:page => params[:page]) unless params[:order]
        @sites = Legacy::LegacySite.select_order(params[:order]).paginate(:page => params[:page]) if params[:order]
    end

    def map
        @legacy_event_id = params[:id]
    end

    def form
        @form = Form.find_by(legacy_event_id: params[:id]).html
    end
  end
end
