module Worker
  class DashboardController < ApplicationController
    include ApplicationHelper
    before_filter :check_user
    def index
    	@unverified_users = !current_user.admin? ? current_user.legacy_organization.users.where(verified:false) : nil
    end
    def verify_user
    	user = User.find(params["user_id"])
        if user.verify!
            InvitationMailer.send_confirmation_alert(current_user,user).deliver_now
        end
    	redirect_to worker_dashboard_path
    end
  end
end
