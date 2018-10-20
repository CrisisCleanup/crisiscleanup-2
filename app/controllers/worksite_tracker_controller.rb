class WorksiteTrackerController < ApplicationController
  def index
    @statuses = [
      ['Open, unassigned', 'Open, unassigned'],
      ['Open, assigned', 'Open, assigned'],
      ['Open, partially completed', 'Open, partially completed'],
      ['Open, needs follow-up', 'Open, needs follow-up'],
      ['Closed, completed', 'Closed, completed'],
      ['Closed, incomplete', 'Closed, incomplete'],
      ['Closed, out of scope', 'Closed, out of scope'],
      ['Closed, done by others', 'Closed, done by others'],
      ['Closed, no help wanted', 'Closed, no help wanted'],
      ['Closed, rejected', 'Closed, rejected'],
      ['Closed, duplicate', 'Closed, duplicate']
    ]
    @print_token = PrintToken.select('*').where(token: params[:token])
      .where('token_expiration > ?', DateTime.now).first
    @site = Legacy::LegacySite.find_by_id(@print_token.legacy_site_id)
    @token = "/z/#{params[:token]}"
    render 'index'
  end
  
  def submit

    if params[:token]
      if @print_token = PrintToken.select('*').where(token: params[:token])
        .where('token_expiration > ?', DateTime.now).first        
        
        # Guard status types
        status = [ "Open, unassigned", "Open, assigned",
          "Open, partially completed", "Open, needs follow-up",
          "Closed, completed", "Closed, incomplete",
          "Closed, out of scope", "Closed, done by others",
          "Closed, no help wanted", "Closed, rejected",
          "Closed, duplicate"]
        if not status.include?(params[:status])
          render status: 404
        else
          if site = Legacy::LegacySite.find(@print_token.legacy_site_id)
            site.status = params[:status] if params[:status]
            if params[:status_notes]
              site.data[:status_notes] = params[:status_notes]
            end
            site.save!
            
            if params[:email]
              @print_token.reporting_email = params[:email]
            end
            if params[:organization_name]
              @print_token.reporting_org_name = params[:organization_name]
            end
            @print_token.save!
            
            render 'thanks'
          else
            render status: 500
          end
        end
      else
        render status: 500
      end
    else
      render status: 404
    end
  end
end
