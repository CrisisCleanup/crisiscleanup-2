class RequestInvitationsController < ApplicationController
    def new
    	@request_invitation = RequestInvitation.new
        @organizations = Legacy::LegacyOrganization.all.order(:name)
    end
    def create       
        @request_invitation = RequestInvitation.new(request_invitation_params)
        if @request_invitation.save
            flash[:notice] = "An invitation request has been send for #{@request_invitation.email}."
         	redirect_to "/login"
        else
            flash[:alert] = "Invitation request not sent"
            render :new
        end 
    end

    private
	    def request_invitation_params
	        params.permit(
            :name, :email, :legacy_organization_id)
	    end
end
