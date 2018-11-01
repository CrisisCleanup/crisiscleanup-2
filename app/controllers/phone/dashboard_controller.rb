module Phone
  class DashboardController < ApplicationController
    include ApplicationHelper
    include ActionView::Helpers::NumberHelper
    before_filter :check_user
    
    private
    
    def update_completion_for_partially_completed_calls(phone_outbound, dnis, selected_phone_status)
      outbound_records = PhoneOutbound.where("id = ? OR dnis1 = ? OR dnis2 = ?
        AND created_at >= (SELECT created_at AS target_created_at FROM phone_outbound WHERE id = ?)", 
        phone_outbound.id, dnis, dnis, phone_outbound.id)
         
      new_completion = selected_phone_status.completion
      outbound_records.each do |record| 
        record.update(completion: record.completion + new_completion)
        record.save!
      end
    end   
    
    public
    
    def index
      if params.has_key?(:phone_outbound_status_id)
        phone_outbound_status = PhoneOutboundStatus.find_by_id(params[:phone_outbound_status_id])
        selected_phone_status = PhoneStatus.find_by_id(params[:phone_status_id])
        
        # Phone is complete
        if @legacy_site = phone_outbound_status.phone_outbound.legacy_site 
          @legacy_site.status = params[:work_order_status] if params[:work_order_status]
          if !params[:status_notes].blank?
            notes = params[:status_notes]
            @legacy_site.data["status_notes"] = notes
          end  
          @legacy_site.save!
        end              
        
        # Check if phone status has completion less than 1
        if selected_phone_status.completion < 1.00
          phone_outbound_status.completion = selected_phone_status.completion
          phone_outbound_status.do_not_call_before = Time.now + selected_phone_status.try_again_delay
          # TODO: dynamic dnis1 or dnis2 - present to user for selection
          phone_outbound_status.dnis = phone_outbound_status.phone_outbound.dnis1
          # phone_outbound_status.uii = ''
          phone_outbound_status.phone_status = selected_phone_status
          if phone_outbound_status.save!
            flash[:notice] = "Call info for #{number_to_phone(params[:selected_dnis], area_code: true)} successfully saved!"
          else
            flash[:alert] = "Call info for #{number_to_phone(params[:selected_dnis], area_code: true)} not saved!"
          end         
          
          # update completion for partially completed outbound phones
          if phone_outbound_status.phone_outbound.present?
            update_completion_for_partially_completed_calls(phone_outbound_status.phone_outbound, params[:selected_dnis], selected_phone_status)         
          end
        else
          phone_outbound_status.phone_status = selected_phone_status
          if phone_outbound_status.save!
            flash[:notice] = "Call info for #{number_to_phone(params[:selected_dnis], area_code: true)} successfully saved!"
          else
            flash[:alert] = "Call info for #{number_to_phone(params[:selected_dnis], area_code: true)} not saved!"
          end
        end
      end     
      
      # Populate drop-downs
      @statuses = worksite_statuses()
      @phone_statuses = [["-- Choose One --", 0]] + PhoneStatus.all.map { |ps| [ps.status, ps.id]}
      
      # check for incomplete calls by user
      @locked_call = PhoneOutbound.get_locked_call_for_user(current_user.id)
          
      if !@locked_call
      
        phone_outbound = PhoneOutbound.select_next_phone_outbound_for_user(current_user.id)
        
        PhoneOutboundStatus.create(
          user_id: current_user.id,
          outbound_id: phone_outbound.id
        )
        
        @locked_call = PhoneOutbound.get_locked_call_for_user(current_user.id)
      end
      
      @available_dnis = []
      @available_dnis << [@locked_call.dnis1, @locked_call.dnis1] if @locked_call.dnis1
      @available_dnis << [@locked_call.dnis2, @locked_call.dnis2] if @locked_call.dnis2
      
      if @locked_call.worksite_id
        @site = Legacy::LegacySite.find_by_id(@locked_call.worksite_id)
      end
        
    end
    
  end
  

end
