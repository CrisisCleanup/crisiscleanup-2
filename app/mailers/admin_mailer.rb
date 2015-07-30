class AdminMailer < ActionMailer::Base
  default from: "help@crisiscleanup.org"
  def send_registration_alert(user, org)
    @user = user
    @org = org
   
    mail(to: @user.email, subject: "#{@org.name} has registered for Crisis Cleanup")
  end

  def send_user_registration_alert(user, org)
  	@user = user
  	@org = org
  	
  	mail(to: @user.email, subject: "#{@user.name} has registered for Crisis Cleanup with #{@org.name}")
  end
 	# TODO - do we need comment alerts? also an in-app mail or alert system, ala social network messages
end
