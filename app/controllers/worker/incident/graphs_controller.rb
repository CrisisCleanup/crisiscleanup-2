module Worker
  module Incident
    class GraphsController < ApplicationController
      include ApplicationHelper
      before_filter :check_incident_permissions

      def index
        @org_name = Legacy::LegacyOrganization.find(current_user.legacy_organization_id).name

      end

      def graphs_site0
        @event = Legacy::LegacyEvent.find(params[:id])
        total = @event.legacy_sites
                    .where("reported_by = ?", current_user.legacy_organization_id)
                    .group_by_day(:created_at).count
        claimed = @event.legacy_sites
                           .where("claimed_by = ?", current_user.legacy_organization_id)
                           .group_by_day(:created_at).count
        closed = @event.legacy_sites
                           .where("status LIKE '%Closed%' AND claimed_by = ?", current_user.legacy_organization_id)
                           .group_by_day(:created_at).count

        r = [
          {name: "Created", data: total},
          {name: "Claimed", data: claimed},
          {name: "Completed", data: closed},
        ]

        render json: r

      end

      def graphs_site1
        @event = Legacy::LegacyEvent.find(params[:id])
        total = @event.legacy_sites
                    .where(:claimed_by => nil)
                    .group_by_day(:created_at).count
        claimed = @event.legacy_sites
                      .where.not(:claimed_by => nil)
                           .group_by_day(:created_at).count
        closed = @event.legacy_sites
                           .where("status LIKE '%Closed%'")
                           .group_by_day(:created_at).count

        r = [
          {name: "Unclaimed", data: total},
          {name: "Claimed", data: claimed},
          {name: "Completed", data: closed}
        ]

        render json: r

      end

      def graphs_site2
        @event = Legacy::LegacyEvent.find(params[:id])
        @total_day = @event.legacy_sites
                         .where("claimed_by = ?", current_user.legacy_organization_id)
                         .group(:status).count

        render json: @total_day

      end

      def graphs_site3
        @event = Legacy::LegacyEvent.find(params[:id])
        total = @event.legacy_sites
                    .where("reported_by = ?", current_user.legacy_organization_id)
                    .group_by_day(:created_at).count
        claimed = @event.legacy_sites
                           .where("claimed_by = ?", current_user.legacy_organization_id)
                           .group_by_day(:created_at).count
        closed = @event.legacy_sites
                           .where("status LIKE '%Closed%' AND claimed_by = ?", current_user.legacy_organization_id)
                           .group_by_day(:created_at).count

        r = [
          {name: "Created", data: total},
          {name: "Claimed", data: claimed},
          {name: "Completed", data: closed},
        ]

        render json: r

      end

      def graphs_site4

        org = Legacy::LegacyOrganization.find(current_user.legacy_organization_id)

        outstanding_invitations = Invitation.where(organization_id: org.id, activated: false).count
        accepted_invitations = Invitation.where(organization_id: org.id, activated: true).count

        r = [["Outstanding Invitations", outstanding_invitations],
          ["Accepted Invitations", accepted_invitations]]

        render json: r

      end

    end
  end
end
