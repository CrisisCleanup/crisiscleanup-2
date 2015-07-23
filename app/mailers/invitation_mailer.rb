class InvitationMailer < ActionMailer::Base
  default from: "admin@crisiscleanup.org"
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
end
