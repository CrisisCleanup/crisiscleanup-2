module Worker
  module Incident
    class LegacyContactsController < ApplicationController
      include ApplicationHelper
      before_filter :check_incident_permissions

      def index
        org_ids = Legacy::LegacyOrganizationEvent.where(legacy_event_id: current_user_event).pluck(:legacy_organization_id)
        @contacts = Legacy::LegacyContact.order("first_name").where(legacy_organization_id: org_ids).paginate(:page => params[:page])
        @event_id = params[:id]
        @users = User.where(legacy_organization_id: current_user.legacy_organization_id)
      end
      
      def edit
        @org = Legacy::LegacyOrganization.find(current_user.legacy_organization_id)
        
        is_editing = params.key?('edit')
        if is_editing
          edit_success = false
          new_contact = params['edit']['new_contacts']
          if new_contact.present?
            if new_contact["_destroy"] == "false"
              lc = Legacy::LegacyContact.new(
                email: new_contact["email"],
                first_name: new_contact["first_name"],
                last_name: new_contact["last_name"],
                phone: new_contact["phone"],
                legacy_organization_id: current_user.legacy_organization_id
              )
              edit_success = lc.save
            end
          end
          
          contacts = params['edit']['contacts']
          if contacts.present?
            contacts.each do |key, value|
              if value["_destroy"] == "true"
                con = Legacy::LegacyContact.find(key)
                con.delete()
              else 
                con = Legacy::LegacyContact.find(key)
                edit_success = con.update_attributes(value.permit(:first_name, :last_name, :phone, :email))
              end
            end
          end       
          
          if edit_success
            flash[:notice] = "Contacts successfully updated"
            redirect_to worker_incident_legacy_contacts_path
          else
            flash[:alert] = "Contacts not saved"
          end    
        end
        
        @contacts = @org.legacy_contacts
      end
      
      def show
        @contact = Legacy::LegacyContact.find(params[:contact_id])
        @event_id = params[:id]
      end
    end
  end
end
