# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  before_filter :load_config

  include AuthenticatedSystem
  require 'rdiscount'

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'd6311deaafe1c8b1e1dd8ed8b84a4855'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def load_config
    @configuration = Configuration.find :first
  end
  
  def show_errors(exception)
    respond_to do |format|
      format.html { 
        flash[:error] = exception.message
        render :action => (exception.record.new_record? ? 'new' : 'edit') 
      }
      format.text { render :text => (exception.record.new_record? ? 'new' : 'edit') + " #{exception.message}" }
      format.xml { render :text => (exception.record.new_record? ? 'new' : 'edit') + " #{exception.message}" }
    end
  end
  
  def admin_required
    access_denied unless logged_in? and current_user.admin? and (current_user.admin? != "false")
  end
  
  def access_denied
    if (current_user != :false)
      render :text => "You do not have permission to access that resource.", :status => 401
      return
    end
    
    respond_to do |accepts|
      accepts.html do
        store_location
        redirect_to "#{CORE_API_URL}/login"
      end
      accepts.xml do
        access_unauthorized
      end
    end
    false
  end
  
end
