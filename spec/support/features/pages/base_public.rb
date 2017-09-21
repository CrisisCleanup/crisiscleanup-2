
module Pages
  class Maps
    include Capybara::DSL

    def select_incident(index)
      incident_select(index)
    end

    private

    def incident_select(index)
      find('.select_incident').find(:xpath, "option[#{index}]").select_option
    end
  end
end