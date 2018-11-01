class PhoneOutboundStatus < ActiveRecord::Base
  self.table_name = 'phone_outbound_status'
  belongs_to :user, foreign_key: "user_id"
  belongs_to :phone_outbound, foreign_key: "outbound_id"
  belongs_to :phone_status, foreign_key: "status_id"
  
end
