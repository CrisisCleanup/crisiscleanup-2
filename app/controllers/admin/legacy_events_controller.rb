module Admin
  class LegacyEventsController < ApplicationController
    include ApplicationHelper
    before_action :check_admin?
    # add logic to only allow ccu admins to access this
    # before_action :deny_access, :unless => :is_ccu_admin?
    def index
        # todo implement search and sort and paginate
        @events = Legacy::LegacyEvent.order("created_date DESC").paginate(:page => params[:page])
    end
    def show
        @event = Legacy::LegacyEvent.find(params[:id])
    end
    def new
    	@event = Legacy::LegacyEvent.new
        @case_label = Legacy::LegacyEvent.next_case_label
    end
    def create    
        @event = Legacy::LegacyEvent.new(event_params) 
        if @event.save
            flash[:notice] = "Event #{@event.name} successfully saved"
         	redirect_to admin_legacy_events_path
        else
            flash[:alert] = "Event #{@event.name} not saved"
            render :new
        end
    
    end
    def edit
        @event = Legacy::LegacyEvent.find(params[:id])
        @versions = @event.versions
        @case_label = @event.case_label
    end

    def update
        @event = Legacy::LegacyEvent.find(params[:id])
        if  @event.update_attributes(event_params)
            flash[:notice] = "Event #{@event.name} successfully updated"
            redirect_to admin_legacy_events_path
        else
            flash[:alert] = "Event #{@event.name} not updated"
            redirect_to edit_admin_legacy_event_path(@event.id)
        end
    end
    private
	    def event_params
	        params.require(:legacy_legacy_event).permit(
	        	{:legacy_organization_ids => []},
                :case_label,
	        	:counties,
	        	:name,
	        	:short_name,
	        	:created_date,
	        	:start_date,:end_date,
	        	:num_sites,:reminder_contents,
	        	:reminder_days
			)
	    end
  end
end

