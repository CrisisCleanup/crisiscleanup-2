module Pages
  class WorkerDashboardPage < BaseWorkerPage
    include Capybara::DSL

    def get_title
      find('h2.center')
    end

    def send_invites(email_addresses)
    	fill_in 'email_addresses', with: email_addresses
    	click_button 'Submit Invites'
    end

    def click_quick_link(name)
      case name
        when "My Organization"
          click_link('my-org-quick-link')
        when "Contacts"
          click_link('contacts-quick-link')
        when "Organizations"
          click_link('org-quick-link')
        when "Stats"
          click_link('stats-quick-link')
        when "Graphs"
          click_link('graphs-quick-link')
      end
    end

  end
end
