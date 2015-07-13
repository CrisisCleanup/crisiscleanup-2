class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :assign_layout
  layout :assign_layout

  def assign_layout
        if admin_dashboard_mode
            'admin_dashboard'
        elsif volunteer_dashboard_mode
            'volunteer_dashboard'          
        end
          
  end

  def admin_dashboard_mode
    self.class.parent == Admin
  end
  def volunteer_dashboard_mode
    self.class.parent == Volunteer
  end

  def after_sign_in_path_for(resource)
    if resource.class == User
      '/dashboard'
    end
  end
end
