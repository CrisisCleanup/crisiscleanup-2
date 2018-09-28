module Admin
  class GroupMailerController < ApplicationController
    include ApplicationHelper
    before_filter :check_admin?

    def index
            
    end
    
    def email 
       
       to_email_list = params[:to_emails].split(/\s*,\s*/)
       
       from_email = params[:from] || 'help@crisiscleanup.org'
       
       subject = params[:subject]
       message_body = params[:body]
       
       GroupMailer.send_group_email(to_email_list, from_email, subject, message_body).deliver_now
    
       render :index
       
     end
  end
end
