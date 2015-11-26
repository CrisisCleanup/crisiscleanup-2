module Admin
  class UsersController < ApplicationController
    include ApplicationHelper
    before_filter :check_admin?
    # add logic to only allow ccu admins to access this
    # before_filter :deny_access, :unless => :is_ccu_admin?
    def index
        # todo implement search and sort and paginate
        @users = User.order("name").paginate(:page => params[:page])
    end
    def new
    	@user = User.new
    end
    def create       
        @user = User.new(site_params) 
        if @user.save
            AdminMailer.send_user_registration_alert(@user ,@org).deliver_now
            flash[:notice] = "User #{@user.name} successfully created"
         	redirect_to admin_users_path
        else
            flash[:alert] = "User not created"
            render :new
        end 
    end
    def edit        
        @user = User.find(params[:id])
    end
    def update
        @user = User.find(params[:id])
        if  @user.update_attributes(site_params)
            flash[:notice] = "User #{@user.name} successfully updated"
            redirect_to admin_users_path
        else
            flash[:notice] = "User #{@user.name} not updated"
            redirect_to edit_admin_user_path(@user.id)
        end
    end
    private
	    def site_params
	        params.require(:user).permit(
            :admin, :email, :name, :password,
            :legacy_organization_id, :verified)
	    end
  end
end
