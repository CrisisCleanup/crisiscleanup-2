module Admin
  class ImportController < ApplicationController
    include ApplicationHelper
    before_filter :check_admin?

    # add logic to only allow ccu admins to access this
    # before_filter :deny_access, :unless => :is_ccu_admin?

    def form

    end
  end
end
