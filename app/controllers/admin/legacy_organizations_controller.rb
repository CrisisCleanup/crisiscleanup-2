module Admin
  class LegacyOrganizationsController < ApplicationController
    include ApplicationHelper
    before_filter :check_admin?
    # add logic to only allow ccu admins to access this
    # before_filter :deny_access, :unless => :is_ccu_admin?
    def index
        @orgs = Legacy::LegacyOrganization.order("name").paginate(:page => params[:page])
        @orgs = @orgs.where(org_verified: true) if params[:verified] == "True"
        @orgs = @orgs.where(org_verified: false) if params[:verified] == "False"
        @orgs = @orgs.where(is_active: true) if params[:active] == "True"
        @orgs = @orgs.where(is_active: false) if params[:active] == "False"

    end
    def new
    	@org = Legacy::LegacyOrganization.new
        @org.legacy_contacts.build
    end
    def create          
        @org = Legacy::LegacyOrganization.new(org_params) 
        if @org.save
            flash[:notice] = "Organization #{@org.name} successfully saved"
         	redirect_to admin_legacy_organizations_path
        else
            flash[:alert] = "Organization #{@org.name} not saved"
            render :new
        end 
    end
    def edit
        @org = Legacy::LegacyOrganization.find(params[:id])
        @versions = @org.versions
    end
    def update
        @org = Legacy::LegacyOrganization.find(params[:id])
        if  @org.update_attributes(org_params)
            flash[:notice] = "Organization #{@org.name} successfully updated"
            redirect_to admin_legacy_organizations_path
        else
            flash[:alert] = "Organization #{@org.name} not updated"
            redirect_to edit_admin_legacy_organization_path(@org.id)
        end
    end
    def verify
        org = Legacy::LegacyOrganization.find(params[:id])
        if org.verify!(current_user)
            emails = org.legacy_contacts.map{|c| c.email }
            list = InvitationList.new(emails.join(','),current_user, org.id)
            if list.valid?
                if list.ready.present?  
                    list.ready.each do |inv|
                        InvitationMailer.send_invitation(inv, request.base_url).deliver_now
                        InvitationMailer.send_registration_confirmation(inv, request.base_url, org).deliver_now
                    end
                end
            end 
        end
        # errors
        redirect_to admin_dashboard_index_path
        
    end

    def destroy
        @org = Legacy::LegacyOrganization.find(params[:id]).delete
        flash[:notice] = "Organization #{@org.name} deleted."
        redirect_to admin_legacy_organizations_path
    end
    private
	    def org_params
	        params.require(:legacy_legacy_organization).permit(
                {:legacy_event_ids => []},
                :activate_by,
                :activated_at,
                :activation_code,
                :activation_code,
                :address,
                :admin_notes,
                :city,
                :deprecated,
                :does_only_coordination,
                :does_only_sit_aware,
                :does_recovery,
                :does_something_else,
                :email,
                :facebook,
                :is_active,
                :is_admin,
                :latitude,
                :longitude,
                :name,
                :not_an_org,
                :only_session_authentication,
                :org_verified,
                :password,
                :permissions,
                :phone,
                :physical_presence,
                :publish,
                :reputable,
                :state,
                :terms_privacy,
                :timestamp_login,
                :timestamp_signup,
                :twitter,
                :url,
                :voad_referral,
                :work_area,
                :zip_code
            )
	    end

    #end private 
  end
end

