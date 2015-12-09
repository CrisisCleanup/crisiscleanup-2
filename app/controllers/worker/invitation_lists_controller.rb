module Worker
  class InvitationListsController < ApplicationController
    include ApplicationHelper
    def create
        organization = params[:organization] || current_user.legacy_organization.id
    	list = InvitationList.new(params[:email_addresses], current_user, organization)
    	if list.valid?
    		if list.ready.present?  
    			list.ready.each do |inv|
    				InvitationMailer.send_invitation(inv, request.base_url).deliver_now
                    RequestInvitation.invited!(inv.invitee_email)
    			end
    		end
        end  
        # if list.rejected.present? then WRITE ERROR HANDLING end
        flash[:notice] = "Invitation sent to #{params[:email_addresses]}"
    	redirect_to current_user.admin ? admin_path : worker_dashboard_path
    end
  end
end
