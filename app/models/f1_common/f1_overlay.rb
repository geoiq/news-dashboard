class F1Overlay < F1CoreResource
  self.element_name= 'overlay'
  self.collection_name = 'overlays'
  self.timeout = F1_APPLICATION_CONNECTION_TIMEOUT
  self.headers["platform_key"] = SUPER_SECRET_PLATFORM_KEY
  
  def has_statistics?(name)
    RAILS_DEFAULT_LOGGER.error "has_statistics? #{name}"
    return nil unless self.columns
    RAILS_DEFAULT_LOGGER.error "  #{self.columns.column.inspect}"
    [self.columns.column].flatten.select {|c| c.name == name }.first.attributes["statistics"]
  end
  
  # the get_attribute method seems not used by the application? -joan
  def get_attribute(index,name)
    self.columns.attributes["column"][index].attributes["statistics"].attributes[name]
  end
  
  def feature_count
    self.attributes["feature_count"]
  end
  
  def bbox
    self.attributes["bbox"]
  end 
  
  def duplicate(new_user)
    F1Overlay.find(id_from_response(self.post(:duplicate, :token => new_user.f1token)),
      :params => {:token => new_user.f1token})  
  end
  
  def parse(token)
    @parse ||= (
      connection.send(:request, 'get', "#{CORE_API_URL}/overlays/#{id}/parse.xml?token=#{token}").body
    )
  end
  
  def column_types(token)
    results = parse(token)
    columns_array = ActiveSupport::XmlMini.parse(results)["overlay"]["column"]
    # XmlMini will extract out element from single element top-level array, so put it back in array
    columns_array = [columns_array] if columns_array.is_a? Hash
    Hash[*columns_array.map { |h| h.values_at('name', 'type') }.flatten]
  end
  
end
