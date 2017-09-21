module Admin
  class UsersController < ApplicationController
    include ApplicationHelper
    before_filter :check_admin?
    # add logic to only allow ccu admins to access this
    # before_filter :deny_access, :unless => :is_ccu_admin?
    def index

      if request.path_parameters[:format] == 'json'
        query = get_users

      end

      respond_to do |format|
        format.html
        format.json { render json: query }
      end
    end

    def new
      @user = User.new
      @organizations = Legacy::LegacyOrganization.select(:id, :name).order(:name)
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
        :accepted_terms, :legacy_organization_id)
    end

    def get_users

      if params[:sort]
        store = params[:sort]
        sort = store.split("|")
      end

      if params[:filter]
        @users = User.joins("LEFT OUTER JOIN legacy_organizations ON legacy_organizations.id = users.legacy_organization_id")
                     .select('users.*, legacy_organizations.name as lg_name')
                     .where("users.name LIKE ? OR users.email LIKE ?", "%#{params[:filter]}%", "%#{params[:filter]}%")
                     .order(params[:sort] ? "#{sort[0]} #{sort[1]}" : "name")
                     .paginate(:page => params["page"], :per_page => 15)

      else
        @users = User.joins("LEFT OUTER JOIN legacy_organizations ON legacy_organizations.id = users.legacy_organization_id")
        .select('users.*, legacy_organizations.name as lg_name')
        .order(params[:sort] ? "#{sort[0]} #{sort[1]}" : "name")
                     .paginate(:page => params["page"], :per_page => 15)
      end

      query = {
          "total": @users.total_entries,
          "per_page": @users.per_page,
          "current_page": @users.current_page,
          "last_page": @users.total_pages,
          "next_page_url":"/admin/users.json?page=#{@users.current_page + 1}",
          "prev_page_url":"/admin/users.json?page=#{@users.current_page == 1 ? 1 : @users.current_page - 1}",
          "from": @users.offset + 1,
          "to": @users.offset + @users.length,
          "data": @users
      }
    end
 end
end
