module WorksiteTrackerHelper
  
  def generate_token
    rand(36*8).to_s(36)
  end
  
end
