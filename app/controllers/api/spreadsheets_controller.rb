require 'csv'

module Api
	class SpreadsheetsController < ApplicationController
		include ApplicationHelper
		before_filter :check_admin?
		def sites
			@sites = Legacy::LegacySite.order("name")
			@sites = @sites.select("blurred_latitude, blurred_longitude, city, claimed_by, legacy_event_id, requested_at, state, status, work_type, data, requested_at") if params[:type] == "deidentified"
			@sites = @sites.where('claimed_by is NULL') if params[:claimed_by] == "false"
			@sites = @sites.where('claimed_by is NOT NULL') if params[:claimed_by] == "true"
			@sites = @sites.where("status LIKE '%Open%'") if params[:open] == "true"
			@sites = @sites.where("status LIKE '%Closed%'") if params[:closed] == "true"
			@sites = @sites.where("work_type LIKE '%Flood%'") if params[:work_type] == "flood"
			@sites = @sites.where("work_type LIKE '%Goods%'") if params[:work_type] == "goods"
			@sites = @sites.where("work_type LIKE '%Trees%'") if params[:work_type] == "trees"
			@sites = @sites.where(legacy_event_id: params[:legacy_event_id].to_i) if is_i? params[:legacy_event_id]
			@sites = @sites.where(claimed_by: params[:claimed_by].to_i) if is_i? params[:claimed_by]
			send_data @sites.to_csv(params: params), :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=export_all.csv"
		end  

		def is_i? string
		       !!(string =~ /\A[-+]?[0-9]+\z/)
	    end
	end
end
