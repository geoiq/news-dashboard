class RemoteRecordNotFoundError < StandardError; end

class F1CoreResource < ActiveResource::Base
  self.site = CORE_API_URL  # defined in environment.rb
  attr_accessor :collection_params
  attr_accessor :element_params
  
  alias_method :default_id_from_response, :id_from_response
  
  self.headers['platform_key'] = SUPER_SECRET_PLATFORM_KEY
  
  def initialize(*args)
    #puts "initializing from #{args.inspect}"
    super(*args)
  end
  
  def id_from_response(response)
    unless response['location'].blank?
      default_id_from_response(response)
    else
      nil
    end
  end

  protected
  def collection_path(options = nil)
    newopts = (options || prefix_options)
    newopts.merge!(@collection_params) unless @collection_params.nil?
    self.class.collection_path(newopts)
  end
  
  def element_path(options = nil)
    newopts = (options || prefix_options)
    newopts.merge!(@element_params) unless @element_params.nil?
    self.class.element_path(id, newopts)
  end

end
