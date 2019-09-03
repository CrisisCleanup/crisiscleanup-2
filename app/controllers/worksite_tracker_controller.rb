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
    @is_logged_in = !current_user.nil?
    
    @print_token = PrintToken.select('*').where(token: params[:token])
      .where('token_expiration > ?', DateTime.now).first
    puts(@print_token.inspect)
    if @print_token
      @site = Legacy::LegacySite.find_by_id(@print_token.legacy_site_id)
      @token = "/z/#{params[:token]}"
      @status_notes = @site.data[:status_notes]
      return render 'index'
    end

    return render 'errors/not_found', status: 404
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
          return render 'errors/not_found', status: 404
        else
          if @legacy_site = Legacy::LegacySite.find_by_id(@print_token.legacy_site_id)
            @legacy_site.status = params[:status] if params[:status]
            updater = ""
            
            if !params[:num_volunteers].blank?
              @legacy_site.data["total_volunteers"] = params[:num_volunteers]
            end           
            
            if !params[:volunteer_hours].blank?
              @legacy_site.data["hours_worked_per_volunteer"] = params[:volunteer_hours]
            end           
            
            if !params[:email].blank?
              updater += "REPORTED BY: #{params[:email]}\n"
              @print_token.reporting_email = params[:email]
            end
            if !params[:organization_name].blank?
              updater += "REPORTED BY ORGANIZATION: #{params[:organization_name]}\n"
              @print_token.reporting_org_name = params[:organization_name]
            end
            updater += "ON: #{Time.now.strftime("%m/%d/%Y")}\n"
            
            # @legacy_site.data_will_change!
            
            if !params[:status_notes].blank?
              notes = "#{params[:status_notes]}\n#{updater}"
              @legacy_site.data["status_notes"] = notes
            end           
            @legacy_site.save!
            @print_token.save!
            
            return render 'thanks'
          else
            return render 'errors/server_error', status: 500
          end
        end
      else
        return render 'errors/server_error', status: 500
      end
    else
      return render 'errors/not_found', status: 404
    end
  end
end
