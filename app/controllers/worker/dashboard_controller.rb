module Worker
  class DashboardController < ApplicationController
    include ApplicationHelper
    before_filter :check_user
    def index
    	@unverified_users = current_user.legacy_organization.users.where(verified:false)
    end
    def verify_user
    	User.find(params["user_id"]).verify!
    	redirect_to worker_dashboard_path
    end
  end
end
