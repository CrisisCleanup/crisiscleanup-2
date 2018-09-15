module Legacy
  class LegacyOrganization < ActiveRecord::Base
    self.per_page = 500
    has_paper_trail
    has_many :legacy_organization_events
    has_many :request_invitations
    has_many :legacy_events, through: :legacy_organization_events
    has_many :users,
      inverse_of: :legacy_organization
    has_many :legacy_contacts,
      inverse_of: :legacy_organization
    validates_presence_of :name
    validates_presence_of :accepted_terms
    
    rails_admin do
      list do
        field :id
        field :name
        field :email
        field :where_are_you_working
        field :url
        field :not_an_org
        field :does_damage_assessment
        field :does_cleanup
        field :does_follow_up
        field :does_rebuilding
        field :does_coordination
        field :does_only_sit_aware
        field :does_something_else
        field :does_other_activity
        field :government
      end
    end

    validates_uniqueness_of :name

    accepts_nested_attributes_for :legacy_contacts, allow_destroy: true
    before_save :set_terms_timestamp
    
    def set_terms_timestamp
      self.accepted_terms_timestamp = DateTime.now
    end

    def verify!(current_user)
      if self.update(org_verified: true, is_active:true)
        true
      else
        false
      end
    end

    def primary_contact_id(organization_id)
      contact = Legacy::LegacyOrganization.find(organization_id).legacy_contacts.find_by(is_primary: true)
      contact.id if contact
    end

    def primary_contact_name(organization_id)
      # contact = Legacy::LegacyOrganization.find(organization_id).legacy_contacts.find_by(is_primary: true)
      # contact.id if contact
      contact = Legacy::LegacyOrganization.find(organization_id).legacy_contacts.find_by(is_primary: true)
      name = "#{contact.first_name} #{contact.last_name}" if contact
      name if contact
    end

    def claimed_site_count event_id
      Legacy::LegacySite.where({ claimed_by: self.id, legacy_event_id: event_id }).count
    end

    def open_site_count event_id
      Legacy::LegacySite
        .where({ claimed_by: self.id, legacy_event_id: event_id })
        .where("status LIKE 'Open%'")
        .count
    end

    def closed_site_count event_id
      Legacy::LegacySite
        .where({ claimed_by: self.id, legacy_event_id: event_id })
        .where("status LIKE 'Closed%'")
        .count
    end

    def reported_site_count event_id
      Legacy::LegacySite.where({ reported_by: self.id, legacy_event_id: event_id }).count
    end
  end
end
