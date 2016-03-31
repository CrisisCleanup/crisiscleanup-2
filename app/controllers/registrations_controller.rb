class RegistrationsController < ApplicationController
  def welcome
  end

  def new
    @org = Legacy::LegacyOrganization.new
    @org.legacy_contacts.build
  end

  def create
    @org = Legacy::LegacyOrganization.new(org_params)
    contacts = params["legacy_legacy_organization"]["legacy_contacts_attributes"]
    if contacts.present?
      contacts.each do |c|
        if c[1]["_destroy"] == "false"
          @org.legacy_contacts << Legacy::LegacyContact.new(
            email: c[1]["email"],
            first_name: c[1]["first_name"],
            last_name: c[1]["last_name"],
            phone: c[1]["phone"]
          )
        end
      end
    end
    unless check_user_emails(params, @org)
      flash[:alert] = "That email address is already being used. You may <a href='/login'>login</a> or <a href='/password/new'>request a new password</a>.".html_safe
      render :new
      return
    end


    if @org.valid?
      @org.legacy_events << Legacy::LegacyEvent.find(params['legacy_legacy_organization']['legacy_events'])
      @org.save
      User.where(admin:true).each do |u|
        AdminMailer.send_registration_alert(u,@org).deliver_now
      end

      @org.legacy_contacts.each do |contact|
        InvitationMailer.send_registration_confirmation(contact.email, @org).deliver_now
      end

      redirect_to "/welcome"
    else
      # with errors
      flash[:alert] = "The organization name #{@org.name} or email #{@org.email} or contact email has already been taken. If you represent an organization that wishes to re-deploy to a new incident, click the 'Re-deploy' link below. If you are a volunteer who wishes to join a new organization, please use a different email address."
      render :new
    end
  end
  private

  def check_user_emails params, org
    emails = [org.name]
    list = params[:legacy_legacy_organization][:legacy_contacts_attributes]
    list.each do |obj|
      emails.append(obj[1][:email])
    end
    emails.each do |email|

      if User.find_by(email: email)
        return false
      end
    end
    return true
  end

  def org_params
    params.require(:legacy_legacy_organization).permit(
      :activate_by,
      :activated_at,
      :activation_code,
      :address,
      :admin_notes,
      :city,
      :deprecated,
      :does_damage_assessment,
      :does_intake_assessment,
      :does_cleanup,
      :does_follow_up,
      :does_minor_repairs,
      :does_rebuilding,
      :does_coordination,
      :government,
      :does_other_activity,
      :where_are_you_working,
      :email,
      :facebook,
      :is_active,
      :is_admin,
      :latitude,
      :longitude,
      :name,
      :not_an_org,
      :only_session_authentication,
      :org_verified,
      :password,
      :permissions,
      :phone,
      :physical_presence,
      :publish,
      :reputable,
      :state,
      :terms_privacy,
      :timestamp_login,
      :timestamp_signup,
      :twitter,
      :url,
      :voad_referral,
      :work_area,
      :zip_code,
      :accepted_terms
    )
  end
end
