class InvitationList 
	extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
	attr_accessor :email_addresses, :string, :sender, :ready, :rejected, :org_id
	validates_presence_of :string
    def initialize(addresses_string, sender, org_id = nil)  
        org_id = org_id || sender.org.id  	
    	if addresses_string.present?
    		@string = addresses_string
    		@sender = sender
    		@org_id = org_id
            @ready = []
    		@rejected = []
    		@email_addresses = parse(@string)
    		self.prepare!
    	end
    end
    def prepare!
    	@email_addresses.each do |ad|
    	 	inv = Invitation.new(user_id: sender.id, invitee_email:ad, organization_id:org_id)
    		inv.save ? @ready << inv : @rejected << inv
    	end
    end

    private
    def parse(string)
    	string.gsub(/\s+/, "").split(',')
    end
end