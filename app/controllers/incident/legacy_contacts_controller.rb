module Incident
  class LegacyContactsController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def index
    	@contacts = Legacy::LegacyContact.paginate(:page => params[:page], :per_page => 50)
    end

    def show
    	@contact = Legacy::LegacyContact.find(params[:contact_id])
    end
  end
end