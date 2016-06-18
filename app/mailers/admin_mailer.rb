class AdminMailer < ActionMailer::Base
  default from: "help@#{Crisiscleanup::Application.config.URL}"
  def send_registration_alert(user, org)
    @user = user
    @org = org

    mail(to: @user.email, subject: "#{@org.name} has registered for Crisis Cleanup")
  end

  def send_user_registration_alert(user, org)
    @user = user
    @org = org
    @name = nil
    if @org
      @name = @org.name
    else
      @name = "the Admin"
    end

    mail(to: @user.email, subject: "#{@user.name} has registered for Crisis Cleanup with #{@name}")
  end
  # TODO - do we need comment alerts? also an in-app mail or alert system, ala social network messages
end
