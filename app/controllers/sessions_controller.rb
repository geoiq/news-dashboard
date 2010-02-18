# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  layout 'admin'

  # render new.rhtml
  def new
    #redirect_to CORE_API_URL + "/login"
  end

  def create
    self.current_user = User.authenticate(params[:login]||params[:session][:login], params[:password]||params[:session][:password])   
    #session[:f1token] = self.current_user.f1token if logged_in?
    respond_to do |format|
      format.html {
        if logged_in?
          redirect_back_or_default('/')
          flash[:notice] = "Logged in successfully"
        end
      }
      format.js {
        if logged_in?
          render :json => {:location => user_url(:id => current_user, :format => :js), :id => current_user.id, :admin => current_user.admin?}, :status => :created
          # head :created, :location => user_url(:id => current_user, :format => :js)
        end
      }
    end
  rescue ActiveResource::UnauthorizedAccess
    respond_to do |format|
      format.html {     
        flash[:error] = "The username or password you entered is incorrect."
        render :action => 'new'
      }
      format.js {
        render(:text => {
            :base => ["The username or password you entered is incorrect."],
            :login => [""],
            :password => [""]
        }.to_json, :status => :accepted)
      }
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
