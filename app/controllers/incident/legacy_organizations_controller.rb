module Incident
  class LegacyOrganizationsController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def index
    end

    def show
    end
  end
end