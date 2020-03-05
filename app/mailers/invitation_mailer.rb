class InvitationMailer < ActionMailer::Base
  default from: "help@crisiscleanup.org"
  def send_invitation(inv, request)
    @user = User.find(inv.user_id)
    @email = inv.invitee_email
    # url = "https://www.crisiscleanup.org"
    # @url = url + "/invitations/activate?token="+inv.token
    @url = invitations_activate_url(token: inv.token)
    mail(to: @email, subject: "#{@user.name} has invited you to join Crisis Cleanup")
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

  def send_redeploy_alert(redeploy_request, user, email, origin_ip)
    @redeploy_request = redeploy_request
    @event = @redeploy_request.legacy_event
    @user = user
    @origin_ip = origin_ip
    @previous_events = []
    user.legacy_organization.legacy_events.order("created_at DESC").each { |event| @previous_events.push(event.name) }
    mail(to: email, subject: "New Redeploy Request")
  end

  def send_redeploy_acceptance(email, from, body, bcc)
    @message = body
    mail(to: email, from: from, subject: "Redeploy Request Accepted", bcc: bcc)
  end

  def send_registration_confirmation(email, org)
    @org = org
    mail(to: email, subject: "Crisis Cleanup Application Received")
  end

  def send_contact_alert(contact, org)
    mail(to: contact.email, subject: "Crisis Cleanup Application Pending Approval")
  end
end
