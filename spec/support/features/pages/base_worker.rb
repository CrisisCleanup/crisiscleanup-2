
module Pages
  class BaseWorkerPage
    include Capybara::DSL

    def click_dashboard_link
      Capybara.match = :first
      click_link "Dashboard"
    end

    def click_contacts_link
      Capybara.match = :first
      click_link "Contacts"
    end

  end
end