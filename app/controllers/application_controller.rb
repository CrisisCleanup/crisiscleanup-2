class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :assign_layout
  layout :assign_layout

  def assign_layout
        if admin_dashboard_mode
            'admin_dashboard'
        elsif worker_dashboard_mode
            'worker_dashboard'      
        elsif incident_dashboard_mode
            'incident_dashboard'                  
        end
  end

  def admin_dashboard_mode
    self.class.parent == Admin
  end
  def worker_dashboard_mode
    self.class.parent == Worker
  end
  def incident_dashboard_mode
    self.class.parent == Incident
  end 

  def after_sign_in_path_for(resource)
  
    if resource.class == User && current_user.admin?
      '/admin/dashboard'
    else
      '/dashboard'
    end
  end
end
