class GroupMailer < ActionMailer::Base
  
  default from: "help@crisiscleanup.org"
  
  def send_group_email(to_email_list, cc_email_list, from_email, subject, message_body)
    
    headers["X-SMTPAPI"] = { :to => to_email_list }.to_json

    mail(to: "ignored@example.com", body: message_body, content_type: "text/html", subject: subject)
  end

end
