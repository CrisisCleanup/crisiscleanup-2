module Admin
  class LegacyContactsController < ApplicationController
    include ApplicationHelper
    before_filter :check_admin?
    # add logic to only allow ccu admins to access this
    # before_filter :deny_access, :unless => :is_ccu_admin?
    def index
        # todo implement search and sort and paginate
        @contacts = Legacy::LegacyContact.all
    end
    def new
    	@contact = Legacy::LegacyContact.new
    end
    def create    
        @contact = Legacy::LegacyContact.new(contact_params) 
        if @contact.save
         	redirect_to admin_legacy_contacts_path
        else
            render :new
        end
    
    end
    def edit
        @contact = Legacy::LegacyContact.find(params[:id])
    end
    def update
        @contact = Legacy::LegacyContact.find(params[:id])
        if  @contact.update_attributes(contact_params)
            redirect_to admin_legacy_contacts_path
        else
            redirect_to edit_admin_legacy_contact_path(@contact.id)
        end
    end
    private
	    def contact_params
	        params.require(:legacy_legacy_contact).permit(:email,:first_name,:last_name,:legacy_organization_id,:is_primary,:phone)
	    end
  end
end

