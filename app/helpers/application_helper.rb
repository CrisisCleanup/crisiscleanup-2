module ApplicationHelper
    def check_admin?
        # here is a method to check if we are logged in
        # if not...redirect
        unless current_user
            redirect_to "/login"
            return
        end

        unless current_user and current_user.admin
            redirect_to "/dashboard"
        end
    end

    def check_user
      if !current_user.present?
        redirect_to '/login'
      end
    end

    def current_user_event
        if current_user and current_user.admin
            request.params[:id]
        else
            current_user.legacy_organization.legacy_organization_events.first.legacy_event_id if current_user and current_user.legacy_organization.legacy_organization_events
        end
    end

    def check_incident_permissions
        if current_user_event.nil?
            redirect_to "/worker/dashboard"
        elsif !current_user.admin 
            if !check_incident(params["id"].to_i)
                flash[:alert] = "You don't have permission to view that event."
                redirect_to "/worker/dashboard"
            end
        end
    end
    def check_incident(event_id)
        event_id == current_user_event 
    end
    def check_token
    	if !Invitation.where(token:params[:token]).present?
    		# add error messages
    		redirect_to root_path
    	end
    end

    def nav_link(content, path)
      class_name = current_page?(path) ? 'active' : ''

      content_tag(:li, :class => class_name) do
        link_to content, path
      end
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
