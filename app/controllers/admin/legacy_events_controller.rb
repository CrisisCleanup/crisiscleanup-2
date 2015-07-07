module Admin
  class LegacyEventsController < ApplicationController
    include ApplicationHelper
    before_filter :check_admin?
    # add logic to only allow ccu admins to access this
    # before_filter :deny_access, :unless => :is_ccu_admin?
    def index

    end
    def new
    	@event = Legacy::LegacyEvent.new
    end
    def create
		       
        @event = Legacy::LegacyEvent.new(event_params) 
        if @event.save
         	render :index
        else
            render :new
        end
    
    end
    private
	    def event_params
	        params.require(:legacy_legacy_event).permit(
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

