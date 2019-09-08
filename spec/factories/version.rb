FactoryGirl.define do
    factory :version, class: PaperTrail::Version do
      item_type "Model"
      item_id 1
      event "add"
      whodunnit true
      object ""
    end
end
