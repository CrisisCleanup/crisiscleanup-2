class UsersController < ApplicationController
  include ApplicationHelper

  def edit
    @user = User.find(params[:id])
  end
 
  def update
    @user = User.find(params[:id])
    if  @user.update_attributes(site_params)
      flash[:notice] = "User #{@user.name} successfully updated"
      redirect_to "/dashboard"
    else
      flash[:notice] = "User #{@user.name} not updated"
      redirect_to edit_user_path(@user.id)
    end
  end

  private
  def site_params
    params.require(:user).permit(
    :role, :mobile, :name, :title)
  end
end