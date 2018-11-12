class PhoneOutboundStatus < ActiveRecord::Base
  self.table_name = 'phone_outbound_status'
  belongs_to :user, foreign_key: "user_id"
  belongs_to :phone_outbound, foreign_key: "outbound_id"
  belongs_to :phone_status, foreign_key: "status_id"
  
  def self.get_latest_for_outbound_id(outbound_id)
    return self.select('id').where(outbound_id: outbound_id).order(:created_at).last
  end
  
end
