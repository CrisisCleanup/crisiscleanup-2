class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :assign_layout
  layout :assign_layout
  before_action :set_paper_trail_whodunnit

  def assign_layout
        if admin_dashboard_mode
            'admin_dashboard'
        elsif worker_dashboard_mode
            'worker_dashboard'      
        end
  end

  def verified_request?
    if request.content_type == "application/json"
      true
    else
      super()
    end
  end

  def map_dashboard_mode
    self.env["REQUEST_URI"].include? "map" or self.env["REQUEST_URI"].include? "form" or self.env["REQUEST_URI"].include? "edit"
  end
  def admin_dashboard_mode
    self.class.parent == Admin
  end
  def worker_dashboard_mode
    self.class.parent == Worker || self.class.parent.parent == Worker
  end


  def after_sign_in_path_for(resource)
    Audit.create(user_id: current_user.id, action: "login")
    if resource.class == User && current_user.admin?
      '/admin/dashboard'
    else
      '/dashboard'
    end
  end
end
