require 'aws-sdk-sns/client'

module Api
  class MessagesController < ApplicationController
    include ApplicationHelper
    before_filter :check_user

    def send_sms

      sns_client = Aws::SNS::Client.new(
          region: 'us-east-1',
          access_key_id: ENV['AWS_ACCESS_KEY_ID'],
          secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      )

      if params['type'] == 'site-info'
        message = retrieve_site_info(params['siteId'])
      end

      begin
        params['numbers'].split(',').each do |number|
          sanitize_number = number.scan(/\d/).join('')
          if !sanitize_number.nil?
            sns_client.publish(phone_number: "+1#{sanitize_number}", message: message)
          end
        end
      rescue
        render json: {'status': 200, 'message': "error", 'message': 'The phone numbers are invalid.'}
      end

      render json: {'status': 200, 'message': "success", 'numbers': params['numbers']}
    end

    private

    def retrieve_site_info(siteId)

      site = Legacy::LegacySite.find(siteId)
      link = URI::escape("https://www.google.com/maps?q=#{site.latitude},#{site.longitude}")
      message = "#{current_user.name} has sent you a worksite from crisiscleanup.org:\n#{site.case_number}\n#{site.name}\n#{site.phone1}\n#{site.address}, #{site.city}, #{site.state}, #{site.zip_code}\n#{link}"

    end


  end
end