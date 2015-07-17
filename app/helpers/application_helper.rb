module ApplicationHelper
    def check_admin?
        # here is a method to check if we are logged in
        # if not...redirect
        check_user
    end
    def check_user
		if !current_user.present?
			redirect_to '/login'
		end
    end
    def check_token
    	if !Invitation.where(token:params[:token]).present?
    		# add error messages
    		redirect_to root_path
    	end
    end

    def organization_claimed_site_count organization_id 
        count = Legacy::LegacySite.where(claimed_by: organization_id).count
    end

    def organization_open_site_count organization_id
        count = Legacy::LegacySite.open_by_organization organization_id
    end

    def organization_closed_site_count organization_id
        count = Legacy::LegacySite.closed_by_organization organization_id
    end

    def organization_reported_site_count organization_id
        count = Legacy::LegacySite.where(reported_by: organization_id).count
    end
end
