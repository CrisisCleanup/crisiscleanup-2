module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern
    def user
      User.find(self.whodunnit.to_i)
    end

    def as_json(options={})
      super(:only => [:created_at, :event])
    end
  end
end

PaperTrail.config.track_associations = false

