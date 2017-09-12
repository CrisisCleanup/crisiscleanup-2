module Admin
  class FormsController < ApplicationController
    include ApplicationHelper
    before_action :check_admin?
    # add logic to only allow ccu admins to access this
    # before_action :deny_access, :unless => :is_ccu_admin?
    def new
    	@event = Legacy::LegacyEvent.find(params["legacy_event_id"])
    	@form = Form.new(legacy_event_id: @event.id, html: Form.default_html)
    end
    def create
        @event = Legacy::LegacyEvent.find(params["legacy_event_id"])
        @form = Form.new(legacy_event_id: @event.id, html: params["form"]["html"])
        @form.save
        flash[:notice] = "Form for #{@event.name} successfully saved"
        redirect_to admin_legacy_event_path(@event.id)
    end
    def edit
        @event = Legacy::LegacyEvent.find(params["legacy_event_id"])
        @form = Form.find(params[:id])
    end
    def update
        @event = Legacy::LegacyEvent.find(params["legacy_event_id"])
        @form = Form.find(params[:id])
        if @form.update(html:params["form"]["html"])
            flash[:notice] = "Form for #{@event.name} successfully updated"
             redirect_to admin_legacy_event_path(@event.id)
        else
            flash[:alert] = "Form for #{@event.name} not updated"
            redirect_to :back
        end 
    end
  end
end
