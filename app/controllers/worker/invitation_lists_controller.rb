module Worker
  class InvitationListsController < ApplicationController
    include ApplicationHelper
   
    def create
    	list = InvitationList.new(params[:email_addresses], current_user)
    	if list.valid?
    		list.prepare!
    		list.ready.send!
    	else
    		redirect_to worker_dashboard_path
    	end
    end
  end
end
