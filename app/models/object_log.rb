class ObjectLog
	include Mongoid::Document
	include Mongoid::Timestamps

	field :version, type: Integer, default: 1

	field :model, type: Hash
	# name, id, model_data

	field :user, type: Hash
	# ip, logged_in?, role, organization, user_data

	field :meta_data, type: Hash
	# any other data we might find interesting later.

    # index({ version: 1 }, { unique: true, name: "version_index" })

	def self.history(model_name, model_id)
		self.where('model.name': model_name).where('model.id', model_id).asc('model.committed_at')
	end

	def self.unusual_changes(model_name, model_id, fields)

	end

	def self.include_relationship(parent, child)

	end


end