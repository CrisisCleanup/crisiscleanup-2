module Admin
  class StatsController < ApplicationController
    include ApplicationHelper
    before_filter :check_admin?
    # add logic to only allow ccu admins to access this
    # before_filter :deny_access, :unless => :is_ccu_admin?
    def index
    	@orgs_count = Legacy::LegacyOrganization.count 
    	@events_count = Legacy::LegacyEvent.count
    	@sites_count = Legacy::LegacySite.count
    	@contacts_count = Legacy::LegacyContact.count
        @users_count = User.count
        @todays_login_count = User.todays_login_count
        @todays_create_and_edit_count = Legacy::LegacySite.todays_create_and_edit_count
        @events = Legacy::LegacyEvent.all
    end

    def by_incident
    	@event = Legacy::LegacyEvent.find(params[:id])
    	org_ids = Legacy::LegacyOrganizationEvent.where(legacy_event_id: @event.id)
    	@orgs = Legacy::LegacyOrganization.where(id: org_ids)
    	@work_type_counts = Legacy::LegacySite.work_type_counts(@event.id)
    	@status_counts = Legacy::LegacySite.status_counts(@event.id)
    end
  end
end
