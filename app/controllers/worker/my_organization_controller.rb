module Worker
  class MyOrganizationController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def index
      @pending_invitations = Invitation
        .select("invitations.*, users.name as user_name")
        .joins("JOIN users ON users.id = invitations.user_id")
        .where(organization_id: current_user.legacy_organization_id, activated: false)
        .order(:invitee_email)
        .paginate(:page => params[:pending_invite_page])
      @users = User.where(legacy_organization_id: current_user.legacy_organization_id).order(:name).paginate(:page => params[:users_page])
    end
  end
end
