module ApplicationHelper
    def check_admin?
        # here is a method to check if we are logged in
        # if not...redirect
    end
    def check_user
		if !current_user.present?
			redirect_to '/login'
		end
    end

end
