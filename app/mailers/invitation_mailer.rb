class InvitationMailer < ActionMailer::Base
  def send_invitation(inv, request)
    @user = User.find(inv.user_id)
    @email = inv.invitee_email
    @url = request + "/invitations/activate?token="+inv.token
    mail(to: @email, subject: "#{@user.email} has invited you to join Crisis Cleanup")
  end
 	# TODO - do we need comment alerts? also an in-app mail or alert system, ala social network messages
end
