FactoryGirl.define do
  factory :phone_outbound_1, :class => PhoneOutbound do
    dnis1 Faker::PhoneNumber.cell_phone
    # dnis2 Faker::PhoneNumber.cell_phone
    dnis1_area_code 918 # Oklahoma
    # dnis2_area_code 502
    inbound_at DateTime.now.to_date
    case_updated_at DateTime.now.to_date
    updated_at DateTime.now.to_date
    # created_at DateTime.now.to_date
    vm_link ''
    call_type 'A'
    # completion
  end
end

