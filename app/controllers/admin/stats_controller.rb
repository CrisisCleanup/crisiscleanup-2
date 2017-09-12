module Admin
  class StatsController < ApplicationController

    include ApplicationHelper

    require 'csv'

    before_action :check_admin?

    # add logic to only allow ccu admins to access this
    # before_action :deny_access, :unless => :is_ccu_admin?

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
      @event = Legacy::LegacyEvent.eager_load(:legacy_organizations, :legacy_sites).find(params[:id])
      @work_types = @event.legacy_sites.select('legacy_sites.*').order(:work_type).group_by(&:work_type)
      @work_orders = @event.legacy_sites.select('legacy_sites.*').order(:status).group_by(&:status)
      filename = Time.now.utc.iso8601.gsub('-', '').gsub(':', '') + "-" + @event.name + ".csv"

      respond_to do |format|
        format.html
        format.csv do
          headers['Content-Disposition'] = "attachment; filename=\"" + filename + "\""
          headers['Content-Type'] ||= 'text/csv'
        end
      end
    end

  end
end
