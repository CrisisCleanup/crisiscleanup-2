class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :admin_dashboard_layout
  layout :admin_dashboard_layout

  def admin_dashboard_layout
        if admin_dashboard_mode
            'admin_dashboard'
        end
  end

  def admin_dashboard_mode
    self.class.parent == Admin
  end

  def after_sign_in_path_for(resource)
    # to do...after we add devise
  end
end
