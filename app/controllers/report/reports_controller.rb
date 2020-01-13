class Report::ReportsController < ApplicationController
  include ApplicationHelper
  before_filter :check_user
  helper_method :reports

  def index
  end

  def reports
    return [
      {
        title: 'Teammates Invited & Active',
        types: 'Numbers that link to a table report showing details; Stacked Line or Bar Chart',
        variables: 'X: Days. Y: Number of people. On Y axis, bottom section is a running total number of activated invitations, top section is total unactivated invitations.',
        icon: 'icon-bar-chart'
      },
      {
        title: 'Claimed, Open, Closed Worksites',
        types: 'Numbers that link to a table report showing details; Stacked Line or Bar Chart',
        variables: 'X: Days. Y: Number of worksites. On Y axis, a stacked running total of open versus closed claimed worksites.',
        icon: 'icon-bar-chart'
      },
      {
        title: 'Est. Commercial Value of Services',
        types: 'N/A',
        variables: 'X: Days. Y: Dollars. On Y axis, a stacked running',
        icon: 'icon-pie-chart'
      },
      {
        title: 'Average Wait Time to Completion',
        types: 'Pie Chart with same variables as the line stacked bar/line chart.',
        variables: 'Number of work sites, and number of days waiting (e.g. 0-3, 4-7, 8-14, etc.)',
        icon: 'icon-pie-chart'
      },
      {
        title: 'Longest Wait Time to Completion',
        types: 'Pie Chart',
        variables: 'Number of work sites, and number of days waiting (e.g. 0-3, 4-7, 8-14, etc.)',
        icon: 'icon-pie-chart'
      },
      {
        title: 'Shortest Wait Time to Completion',
        types: 'Pie Chart',
        variables: 'Number of work sites, and number of days waiting (e.g. 0-3, 4-7, 8-14, etc.)',
        icon: 'icon-pie-chart'
      },
      {
        title: 'Number of Open (unassigned) worksites claimed for more than 6 days',
        types: 'Numbers that link to a table report showing details; Stacked Line or Bar Chart',
        variables: 'N/A',
        icon: 'icon-bar-chart'
      },
      {
        title: 'Detailed Work Logs with Volunteer Hours',
        types: 'Type(s): Sortable Table/ CSV; line or bar chart',
        variables: 'A row for each volunteer check in/check out, location of check in, time checked in, duration of service, etc.',
        icon: 'icon-bar-chart'
      }
    ]
  end
end
