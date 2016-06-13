class UsersController < ApplicationController
  include ApplicationHelper
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
end