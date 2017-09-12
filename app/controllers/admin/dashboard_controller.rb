module Admin
  class DashboardController < ApplicationController
    include ApplicationHelper
    before_action :check_admin?
    # add logic to only allow ccu admins to access this
    # before_action :deny_access, :unless => :is_ccu_admin?
    def index
    	@orgs = Legacy::LegacyOrganization.where(org_verified:false).order('name ASC')
    end
  end
end
