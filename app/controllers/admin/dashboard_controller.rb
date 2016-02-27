module Admin
  class DashboardController < ApplicationController
    include ApplicationHelper
    before_filter :check_admin?
    # add logic to only allow ccu admins to access this
    # before_filter :deny_access, :unless => :is_ccu_admin?
    def index
    	# binding.pry
    	@orgs = Legacy::LegacyOrganization.where(org_verified:false).order('created_at ASC')
    end
  end
end
