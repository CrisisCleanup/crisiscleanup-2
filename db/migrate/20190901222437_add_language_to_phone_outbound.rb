class AddLanguageToPhoneOutbound < ActiveRecord::Migration
  def change
  	add_column :phone_outbound, :language, :string
  end
end
