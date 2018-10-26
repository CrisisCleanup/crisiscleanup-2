require 'rqrcode'

module WorksiteTrackerHelper
  
  def generate_token
    rand(36*8).to_s(36)
  end
  
  def generate_qr(token_url)
    return RQRCode::QRCode.new(token_url)
  end
  
end
