
module Pages
  class BaseWorkerPage
    include Capybara::DSL

    def click_dashboard_link
      Capybara.match = :first
      link = find(:xpath, "//a[contains(text(), 'Dashboard')]")
      link.click
    end

    def click_contacts_link
      Capybara.match = :first
      link = find(:xpath, "//a[contains(text(), 'Contacts')]")
      link.click
    end

  end
end