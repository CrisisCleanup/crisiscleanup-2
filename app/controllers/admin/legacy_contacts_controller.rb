module Admin
  class LegacyContactsController < ApplicationController
    include ApplicationHelper
    before_action :check_admin?
    # add logic to only allow ccu admins to access this
    # before_action :deny_access, :unless => :is_ccu_admin?
    def index
      # todo implement search and sort and paginate
      @contacts = Legacy::LegacyContact.order("first_name").paginate(:page => params[:page])
    end
    def new
      @contact = Legacy::LegacyContact.new
    end
    def create
      @contact = Legacy::LegacyContact.new(contact_params)
      if @contact.save
        flash[:notice] = "Contact #{@contact.first_name} #{@contact.last_name} successfully saved"
        redirect_to admin_legacy_contacts_path
      else
        flash[:alert] = "Contact #{@contact.first_name} #{@contact.last_name} not saved"
        render :new
      end

    end
    def edit
      @contact = Legacy::LegacyContact.find(params[:id])
      @versions = @contact.versions
    end

    def update
      @contact = Legacy::LegacyContact.find(params[:id])
      if  @contact.update_attributes(contact_params)
        flash[:notice] = "Contact #{@contact.first_name} #{@contact.last_name} successfully updated"
        redirect_to admin_legacy_contacts_path
      else
        flash[:alert] = "Contact #{@contact.first_name} #{@contact.last_name} not updated"
        redirect_to edit_admin_legacy_contact_path(@contact.id)
      end
    end

    private
    def contact_params
      params.require(:legacy_legacy_contact)
        .permit(:email,
                :first_name,
                :last_name,
                :legacy_organization_id,
                :organizational_title,
                :is_primary,
                :phone)
    end
  end
end

