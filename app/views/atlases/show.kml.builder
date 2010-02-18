xml.kml("xmlns" => "http://earth.google.com/kml/2.2", 
"xmlns:atom" => "http://www.w3.org/2005/Atom") do
  xml.tag! "Document" do
    xml.name @atlas.title
    xml.Style :id => "mapBounds" do
      xml.PolyStyle do
        xml.color "77209600"
      end
    end
    xml.Style :id => "dataBounds" do
      xml.PolyStyle do
        xml.color "77F4CC77"
      end
    end
    @atlas.map_lists.each do |map_list|
      xml.Folder do
        xml.name map_list.title
        xml.description map_list.description
        map_list.maps_sort_order.split(",").each do |map|
          xml.NetworkLink do
            xml.name "name"
            xml.Link do
              xml.href  MAKER_API_URL + "/maps/#{map}.kml"
            end
          end
        end
      end
    end
  end
end
