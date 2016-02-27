class InvitationMailer < ActionMailer::Base
  default from: "help@crisiscleanup.org"
  def send_invitation(inv, request)
    @user = User.find(inv.user_id)
    @email = inv.invitee_email
    @url = request + "/invitations/activate?token="+inv.token
    mail(to: @email, subject: "#{@user.email} has invited you to join Crisis Cleanup")
  end
  def send_confirmation_alert(verified_by, new_user)
    @verified_by = verified_by
    @new_user = new_user
   
    mail(to: @new_user.email, subject: "#{@verified_by.email} has granted you access")
  end

  # TODO - do we need comment alerts? also an in-app mail or alert system, ala social network messages
  def send_incident_request(params, email)
    @name = params[:name]
    @email = params[:email]
    @phone = params[:phone]
    @title = params[:title]
    @details = params[:details]
    mail(to: email, subject: "New Incident Request")
  end

  def send_redeploy_alert(event, user, email)
    @event = event
    @user = user
    mail(to: email, subject: "New Redeploy Request")
  end

  def send_registration_confirmation(inv, request, org)
    @user = User.find(inv.user_id)
    @email = inv.invitee_email
    @url = request + "/invitations/activate?token="+inv.token
    @org = org
    mail(to: @email, subject: "#{@user.email} has invited you to join Crisis Cleanup")
  end
end
