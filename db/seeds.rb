@u = User.create(email:'admin@aol.com', password:'blue32blue32', name:'frank', admin:true)

5.times do
  legacy_event = Legacy::LegacyEvent.create(
    case_label: Faker::Company.bs,
    name: Faker::Address.city + " Disaster",
    short_name: 'Disaster',
    created_date:  DateTime.now.to_date,
    start_date: DateTime.now.to_date,
    end_date: DateTime.now.to_date,
    reminder_contents: Faker::Lorem.sentence,
    reminder_days: 12
    )
    form = Form.create(
      legacy_event_id: legacy_event.id
    )

  5.times do
    org = Legacy::LegacyOrganization.create(
      activate_by: DateTime.now.to_date,
      activated_at: DateTime.now.to_date,
      activation_code: Faker::Code.ean,
      address: Faker::Address.street_address,
      admin_notes: Faker::Lorem.sentence,
      city: Faker::Address.city,
      email: Faker::Internet.email,
      facebook: Faker::Internet.url('facebook.com'),
      is_active: true,
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      name:   Faker::Team.name,
      password:  Faker::Internet.password,
      permissions: Faker::Lorem.word,
      phone: Faker::PhoneNumber.cell_phone,
      physical_presence:true,
      publish:true,
      reputable:true,
      state: Faker::Address.state,
      terms_privacy:Faker::Lorem.sentence,
      timestamp_login:DateTime.now,
      timestamp_signup:DateTime.now,
      twitter:Faker::Internet.url('twitter.com'),
      url:Faker::Internet.url('example.com'),
      work_area:Faker::Lorem.sentence,
      zip_code: Faker::Address.zip,
      is_admin: true
    )
    Legacy::LegacyOrganizationEvent.create(legacy_organization_id: org.id, legacy_event_id: 1)

    User.create(email:'frank@aol.com', password:'blue32blue32', name:'frank', admin:false, legacy_organization_id:org.id, referring_user_id:@u.id)

    2.times do
      Legacy::LegacyContact.create(
        email: Faker::Internet.email,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        legacy_organization_id: org.id,
        phone: Faker::PhoneNumber.cell_phone
      )
    end
  end

  5.times do
    Legacy::LegacySite.create(
      address: Faker::Address.street_address,
      latitude:  Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      blurred_latitude:  Faker::Address.latitude,
      blurred_longitude: Faker::Address.longitude,
      case_number: Faker::Code.isbn,
      city: Faker::Address.city,
      legacy_event_id: legacy_event.id,
      name:     Faker::Address.city + 'Disaster',
      phone:       Faker::PhoneNumber.cell_phone,
      reported_by: 1,
      request_date: DateTime.now.to_date,
      state:     Faker::Address.state,
      status: [
        "Open, unassigned",
        "Open, assigned",
        "Open, partially completed",
        "Open, needs follow-up",
        "Closed, completed",
        "Closed, incomplete",
        "Closed, out of scope",
        "Closed, done by others",
        "Closed, no help wanted",
        "Closed, rejected",
        "Closed, duplicatei"
      ].sample,
      work_type: ["Flood","Report","Debris","Other"].sample
    )
  end

end
