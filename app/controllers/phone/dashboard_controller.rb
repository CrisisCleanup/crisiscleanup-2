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
    
    def update_completion_for_completed_calls(phone_outbound, dnis, selected_phone_status)
       outbound_records = PhoneOutbound.where("id = ? OR dnis1 = ? OR dnis2 = ?
        AND created_at >= (SELECT created_at AS target_created_at FROM phone_outbound WHERE id = ?)", 
        phone_outbound.id, dnis, dnis, phone_outbound.id)
         
      outbound_records.each do |record| 
        record.update(completion: 1.00)
        record.save!
      end     
    end
    
    public
    
    def index
      
      logger.debug("DEBUGPARAMS: #{params}")
      if params.has_key?(:phone_outbound_status_id)
        phone_outbound_status = PhoneOutboundStatus.find_by_id(params[:phone_outbound_status_id])
        selected_phone_status = PhoneStatus.find_by_id(params[:phone_status_id])
        logger.debug("1 - #{phone_outbound_status.inspect}")
        logger.debug("2 - #{selected_phone_status.inspect}")
        
        # Phone is complete
        if !phone_outbound_status.nil?
          if @legacy_site = phone_outbound_status.phone_outbound.legacy_site 
            if !params[:status_notes].blank?
              existing_notes = @legacy_site.data["status_notes"]
              notes = params[:status_notes]
              @legacy_site.data["status_notes"] = "#{existing_notes}\n#{notes}"
            end  
            @legacy_site.save!
          end              
        end
        
        # Check if phone status has completion less than 1
        if ((selected_phone_status.completion < 1.00))
          logger.debug("2.1 - #{phone_outbound_status.inspect}")
          phone_outbound_status.completion = selected_phone_status.completion
          phone_outbound_status.do_not_call_before = Time.now + selected_phone_status.try_again_delay
          phone_outbound_status.dnis = phone_outbound_status.phone_outbound.dnis1
          phone_outbound_status.phone_status = selected_phone_status
          if phone_outbound_status.save
            logger.debug("2.2 - #{phone_outbound_status.inspect}")
            flash[:notice] = "Call info for #{number_to_phone(params[:selected_dnis], area_code: true)} successfully saved!"
          else
            logger.debug("2.3 - #{phone_outbound_status.inspect}")
            flash[:alert] = "Call info for #{number_to_phone(params[:selected_dnis], area_code: true)} not saved!"
          end         
          
          # update completion for partially completed outbound phones
          if phone_outbound_status.phone_outbound.present?
            update_completion_for_partially_completed_calls(phone_outbound_status.phone_outbound, params[:selected_dnis], selected_phone_status)         
          end
        else
          phone_outbound_status.completion = selected_phone_status.completion
          phone_outbound_status.dnis = phone_outbound_status.phone_outbound.dnis1
          phone_outbound_status.phone_status = selected_phone_status
          logger.debug("3.1 - #{phone_outbound_status.inspect}")
          if phone_outbound_status.save
            logger.debug("3.2 - #{phone_outbound_status.inspect}")
            flash[:notice] = "Call info for #{number_to_phone(params[:selected_dnis], area_code: true)} successfully saved!"
          else
            logger.debug("3.3 - #{phone_outbound_status.inspect}")
            flash[:alert] = "Call info for #{number_to_phone(params[:selected_dnis], area_code: true)} not saved!"
          end
          
          if phone_outbound_status.phone_outbound.present?
            update_completion_for_completed_calls(phone_outbound_status.phone_outbound, params[:selected_dnis], selected_phone_status)         
          end         
        end
      end     
      
      # Populate drop-downs
      @statuses = worksite_statuses()
      @phone_statuses = [["-- Choose One --", 0]] + PhoneStatus.all.map { |ps| [ps.status, ps.id]}
      
      # check for incomplete calls by user
      @locked_call = PhoneOutbound.get_locked_call_for_user(current_user.id)
      logger.debug("5 - #{@locked_call.inspect}")
      
      @available_language_filters = ['English', 'Spanish']
      if session['call_language_filter'].nil?
        @call_language_filter = 'English'
      else
        @call_language_filter = session[:call_language_filter] 
      end      
      
  
          
      #############################
      # Get a new call off the queue
      #############################
      if !@locked_call
        
        # Check for state filters
        current_state_filter = current_user.legacy_organization.call_state_filter
        logger.debug("6.1 - #{current_state_filter}")
        if !current_state_filter.nil? && current_state_filter != 'None'
          phone_outbound = PhoneOutbound.select_next_phone_outbound_for_user_with_state_filter(current_user.id, current_state_filter, @call_language_filter)
          logger.debug("6.2 - New PhoneOutbound WITH state filter")
          logger.debug("6.2 - #{phone_outbound.inspect}")
        else
          phone_outbound = PhoneOutbound.select_next_phone_outbound_for_user(current_user.id, @call_language_filter)
          logger.debug("6.3 - New PhoneOutbound WITHOUT state filter")
        end
        logger.debug("6.4 - #{@locked_call.inspect}")
        
        if phone_outbound.nil?
          return render :done
        end 
        
        PhoneOutboundStatus.create(
          user_id: current_user.id,
          outbound_id: phone_outbound.id
        )
        
        @locked_call = PhoneOutbound.get_locked_call_for_user(current_user.id)
        logger.debug("7 - #{@locked_call.inspect}")
      end
      
      @locked_call_current_phone_outbound_status = PhoneOutboundStatus.get_latest_for_outbound_id(@locked_call.id)
      logger.debug("5.1 - #{@locked_call_current_phone_outbound_status.inspect}")     
      
      @available_dnis = []
      @available_dnis << [@locked_call.dnis1, @locked_call.dnis1] if @locked_call.dnis1
      @available_dnis << [@locked_call.dnis2, @locked_call.dnis2] if @locked_call.dnis2
      
      @remaining_callbacks = PhoneOutbound.remaining_callbacks(@call_language_filter)
      @remaining_calldowns = PhoneOutbound.remaining_calldowns(@call_language_filter)    
      
      if @locked_call.worksite_id
        @site = Legacy::LegacySite.find_by_id(@locked_call.worksite_id)
      end
        
    end
    
    def change_call_language
      if params.has_key?(:phone_outbound_status_id)
        PhoneOutboundStatus.find_by_id(params[:phone_outbound_status_id]).destroy();
      end     
      if params.has_key?(:call_language_filter)
        session[:call_language_filter] = params[:call_language_filter]
      end
      return redirect_to phone_phone_dashboard_path
    end
    
    def cancel
      if params.has_key?(:phone_outbound_status_id)
        PhoneOutboundStatus.find_by_id(params[:phone_outbound_status_id]).destroy();
      end
      return redirect_to worker_dashboard_path
    end
    
    def done
      @available_language_filters = ['English', 'Spanish']
      if session['call_language_filter'].nil?
        @call_language_filter = 'English'
      else
        @call_language_filter = session[:call_language_filter] 
      end   
    end
    
  end
  

end
