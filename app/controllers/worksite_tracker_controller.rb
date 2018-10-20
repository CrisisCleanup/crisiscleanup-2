class WorksiteTrackerController < ApplicationController
  def index
    @print_token = PrintToken.select('*').where(token: params[:token])
      .where('token_expiration > ?', DateTime.now).first
    @site = Legacy::LegacySite.find_by_id(@print_token.legacy_site_id)
      # @sites = Legacy::LegacySite.where(legacy_event_id: current_user_event)
      # @sites = @sites.where("user_id = ?", current_user.id)
    render 'index'
  end
end
