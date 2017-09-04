
module Pages
  class BaseAdminPage
    include Capybara::DSL

    def click_admin_link
      Capybara.match = :first
      link = find(:xpath, "//a[contains(text(), 'Admin')]")
      link.click
    end

  end
end