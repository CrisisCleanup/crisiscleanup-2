FactoryGirl.define do
  factory :phone_outbound_1, :class => PhoneOutbound do
    dnis1 4051234567
    # dnis2 Faker::PhoneNumber.cell_phone
    dnis1_area_code 405 # Oklahoma
    # dnis2_area_code 502
    inbound_at DateTime.now.to_date
    # case_updated_at DateTime.now.to_date
    updated_at DateTime.now.to_date
    # created_at DateTime.now.to_date
    vm_link ''
    call_type 'A'
    completion 0
  end
  
  factory :phone_outbound_2, :class => PhoneOutbound do
    dnis1 4051234567
    # dnis2 Faker::PhoneNumber.cell_phone
    dnis1_area_code 405 # Oklahoma
    # dnis2_area_code 502
    inbound_at DateTime.now.to_date
    # case_updated_at DateTime.now.to_date
    updated_at DateTime.now.to_date
    # created_at DateTime.now.to_date
    vm_link ''
    call_type 'A'
    completion 0
  end 
end

