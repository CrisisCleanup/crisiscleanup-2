module Admin
  class LegacyOrganizationsController < ApplicationController
    include ApplicationHelper
    before_filter :check_admin?
    # add logic to only allow ccu admins to access this
    # before_filter :deny_access, :unless => :is_ccu_admin?
    def index
        # todo implement search and sort and paginate
        @orgs = Legacy::LegacyOrganization.all
    end
    def new
    	@org = Legacy::LegacyOrganization.new
    end
    def create    
        
        @org = Legacy::LegacyOrganization.new(org_params) 
        if @org.save
         	redirect_to admin_legacy_organizations_path
        else
            render :new
        end
    
    end
    def edit
        @org = Legacy::LegacyOrganization.find(params[:id])
    end
    def update
        
        @org = Legacy::LegacyOrganization.find(params[:id])
        
        if  @org.update_attributes(org_params)
          
            redirect_to admin_legacy_organizations_path
        else
            redirect_to edit_admin_legacy_organization_path(@org.id)
        end
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

