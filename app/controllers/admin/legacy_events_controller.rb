module Admin
  class LegacyEventsController < ApplicationController
    include ApplicationHelper
    before_filter :check_admin?
    # add logic to only allow ccu admins to access this
    # before_filter :deny_access, :unless => :is_ccu_admin?
    def index
        # todo implement search and sort and paginate
        @events = Legacy::LegacyEvent.paginate(:page => params[:page], :per_page => 20)
    end
    def new
    	@event = Legacy::LegacyEvent.new
    end
    def create    
        @event = Legacy::LegacyEvent.new(event_params) 
        if @event.save
         	redirect_to admin_legacy_events_path
        else
            render :new
        end
    
    end
    def edit
        @event = Legacy::LegacyEvent.find(params[:id])
        @versions = @event.versions
    end

    def update
        @event = Legacy::LegacyEvent.find(params[:id])
        if  @event.update_attributes(event_params)
            redirect_to admin_legacy_events_path
        else
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

