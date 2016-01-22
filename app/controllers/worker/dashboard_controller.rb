module Worker
  class DashboardController < ApplicationController
    include ApplicationHelper
    before_filter :check_user
    def index
        @requested_invitations = RequestInvitation.where(user_created: false, legacy_organization_id: current_user.legacy_organization_id).order(:name)
    end
  end
end
