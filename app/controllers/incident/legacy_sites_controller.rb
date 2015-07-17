module Incident
  class LegacySitesController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def index

    end
  end
end
