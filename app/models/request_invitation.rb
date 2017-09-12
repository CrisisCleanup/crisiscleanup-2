class RequestInvitation < ApplicationRecord
	belongs_to :legacy_organization
	validates_presence_of :name, :email
	validates_uniqueness_of :email

	def self.invited!(email)
		obj = find_by(email: email)
		if obj
			obj.invited = true
			obj.save
		end
	end

	def self.user_created!(email)
		obj = find_by(email: email)
		if obj
			obj.user_created = true
			obj.save
		end
	end
end