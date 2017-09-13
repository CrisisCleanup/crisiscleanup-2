class TemporaryPassword < ActiveRecord::Base
	has_secure_password
end