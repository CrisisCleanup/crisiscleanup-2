FactoryGirl.define do
  factory :phone_outbound_1, :class => PhoneOutbound do
    dnis1 4051234567
    dnis1_area_code 405 # Oklahoma
    inbound_at DateTime.now.to_date
    # case_updated_at DateTime.now.to_date
    updated_at DateTime.now.to_date
    vm_link ''
    call_type 'A'
    completion 0
  end
  
  factory :phone_outbound_2, :class => PhoneOutbound do
    dnis1 8501234567
    dnis2 4051234567
    dnis1_area_code 850 
    dnis2_area_code 405 # Oklahoma
    inbound_at DateTime.now.to_date
    updated_at DateTime.now.to_date
    vm_link ''
    call_type 'A'
    completion 0
  end 
end

