module Worker
  class InvitationListsController < ApplicationController
    include ApplicationHelper
   
    def create
    	list = InvitationList.new(params[:email_addresses], current_user)
    	if list.valid?
    		if list.ready.present?  
    			list.ready.each do |inv|
    				InvitationMailer.send_invitation(inv, request.base_url).deliver_now
    			end
    			redirect_to worker_dashboard_path
    		end
        end  
        # if list.rejected.present? then WRITE ERROR HANDLING end
    	redirect_to worker_dashboard_path
    end
  end
end
