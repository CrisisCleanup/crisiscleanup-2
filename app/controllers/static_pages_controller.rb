class StaticPagesController < ApplicationController
  def index
  end
  def about
      render :layout => 'application_sidebar'
  end
  def public_map
      @events = Legacy::LegacyEvent.all
      render :layout => 'application_sidebar'
  end
  def privacy
  end
  def terms
  end      

  def signup
  end

  def new_incident
  end

  def request_incident
    @users = User.where(admin:true)
    @users.each do |user| 
      InvitationMailer.send_incident_request(params, user.email).deliver_now
    end
    flash[:notice] = "Your request has been received"
    redirect_to "/"
  end

  def redeploy
  end

  def donate
    redirect_to "https://www.crowdrise.com/CrisisCleanup"
  end

  def contact
  end
end
