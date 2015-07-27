module Admin
  class LegacySitesController < ApplicationController
    include ApplicationHelper
    before_filter :check_admin?
    # add logic to only allow ccu admins to access this
    # before_filter :deny_access, :unless => :is_ccu_admin?
    def index
        # todo implement search and sort and paginate
        @sites = Legacy::LegacySite.order("case_number").paginate(:page => params[:page])
    end
    def new
    	@site = Legacy::LegacySite.new
    end
    def create       
        @site = Legacy::LegacySite.new(site_params) 
        if @site.save
         	redirect_to admin_legacy_sites_path
            binding.pry
        else
            render :new
        end 
    end
    def edit        
        @site = Legacy::LegacySite.find(params[:id])
        @versions = @site.versions
    end
    def update
        @site = Legacy::LegacySite.find(params[:id])
        if  @site.update_attributes(site_params)
            redirect_to admin_legacy_sites_path
        else
            redirect_to edit_admin_legacy_site_path(@site.id)
        end
    end
    private
	    def site_params
	        params.require(:legacy_legacy_site).permit(
            :address,:blurred_latitude,:blurred_longitude,
            :case_number,:city,:claimed_by,:legacy_event_id,
            :latitude,:longitude,:name,:phone,:reported_by,
            :requested_at,:state,:status,:work_type,:data,:zip_code)
	    end
  end
end
