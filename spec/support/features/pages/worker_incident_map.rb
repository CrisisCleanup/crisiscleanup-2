module Pages
  class WorkerIncidentMapPage < BaseWorkerPage
    include Capybara::DSL

    def go_to(id)
      visit "/worker/incident/#{id}/map"
    end

    def your_location_btn
      find(:xpath, "//button[@title='Your Location']")
    end

    def legend
      find(:xpath, '//img[@class="legend"]')
    end

    def map_infobox
      find('#map-infobox')
    end

    def get_site_marker(site_case_number)
      find(:xpath, "//div[@class='gmnoprint' and @title='#{site_case_number}']//img").trigger("click")
    end

    def click_infobox_print
      find(:xpath, '//a[@id="infobox-print"]').trigger('click')
    end

    def click_claim_site
      find(:xpath, '//a[@id="infobox-claim"]').trigger('click')
    end

    def click_unclaim_site
      find(:xpath, '//a[@id="infobox-unclaim"]').trigger('click')
    end

  end
end
