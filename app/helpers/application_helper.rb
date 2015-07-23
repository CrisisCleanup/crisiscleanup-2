module ApplicationHelper
    def check_admin?
        # here is a method to check if we are logged in
        # if not...redirect
        unless current_user and current_user.admin
            redirect_to "/login"
        end
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

    #TODO these belong in the model
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
    def link_to_add_contact(name, f, association)
        new_object = f.object.send(association).klass.new
        id = new_object.object_id
        fields = f.simple_fields_for(association, new_object, child_index: id) do |builder|
          render(association.to_s.singularize + "_form", contact: builder)
        end
        link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
    end    
end
