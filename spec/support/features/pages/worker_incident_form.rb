module Pages
  class WorkerIncidentFormPage < BaseWorkerPage
    include Capybara::DSL

    def go_to(id)
      visit "/worker/incident/#{id}/form"
    end

    def fill_form(site)
      fill_in("Resident Name", with: site.name) if site.name?
      fill_in("Street Address", with: site.address) if site.address?
      fill_in("City", with: site.city) if site.city?
      if site.county?
        find(".legacy_legacy_site_county > div > label > small > a").click
        fill_in("legacy_legacy_site_county", with: site.county)
      end
      if site.latitude? && site.longitude?
        find('#legacy_legacy_site_latitude', visible: false).set site.latitude
        find('#legacy_legacy_site_longitude', visible: false).set site.longitude
      end
      fill_in("State", with: site.state) if site.state
      fill_in("Zip Code", with: site.zip_code) if site.zip_code
      # fill_in("Cross Street or Nearby Landmark", with: site.cross_street) if site.cross_street.present?

      fill_in("legacy_legacy_site_phone1", with: site.phone1) if site.phone1?
      # fill_in("legacy_legacy_site_phone2", with: site.phone2) if site.phone2.present?

      select(site.work_type, from: 'legacy_legacy_site_work_type') if site.work_type?
      fill_in("Email", with: site.data[:email]) if site.data[:email]

      # select(site.residence_type, from: 'Residence Type') if site.residence_type.present?

      select("House", from: 'legacy_legacy_site_dwelling_type')
      select("Own", from: 'legacy_legacy_site_rent_or_own')
      check("Work without resident present?")
    end

    def fill_out_form(site)
      fill_in("Resident Name", with: site.name)
      fill_in("Street Address", with: site.address)
      # sleep(3)
      # find('div.pac-container > div:nth-child(1)').click
      fill_in("City", with: site.city)
      fill_in("State", with: site.state)
      find(".legacy_legacy_site_county > div > label > small > a").click
      fill_in("legacy_legacy_site_county", with: site.county)
      fill_in("Zip Code", with: site.zip_code)
      find('#legacy_legacy_site_latitude', visible: false).set site.latitude
      find('#legacy_legacy_site_longitude', visible: false).set site.longitude
      fill_in("Cross Street or Nearby Landmark", with: "Some cross street")
      fill_in("legacy_legacy_site_phone1", with: site.phone1)
      select("House", from: 'legacy_legacy_site_dwelling_type')
      select("Trees", from: 'legacy_legacy_site_work_type')
      select("Own", from: 'legacy_legacy_site_rent_or_own')
      check("Work without resident present?")
    end

    def skip_and_save
      click_button('skip_and_save')
    end

    def save_form
      click_button('save-form-btn')
    end

    def claim_and_save_form
      click_button('Save & Claim')
    end

    def reset_form
      click_link('Reset')
    end

  end
end
