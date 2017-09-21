xml.instruct!
xml.kml("xmnls" => "http://www.opengis.net/kml/2.2") do
  xml.Document do
    xml.Name @event.name
    xml.Camera do
      xml.longitude 37
      xml.latitude -95
      xml.altitude 500000
      xml.altitudeMode "absolute"
    end
    @sites.each do |site|
      xml.Placemark do
        xml.name site.address
        xml.Description do
          xml.cdata! "<span>#{ site.lg_name.present? ? site.lg_name : "Unclaimed"}</span> <span>#{site.work_type}</span> <span>#{site.status}</span>"
        end
        xml.Point do
          xml.coordinates "#{site.longitude}, #{site.latitude}"
        end
      end
    end
  end
end


