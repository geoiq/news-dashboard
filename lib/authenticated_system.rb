module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      current_user != :false
    end
    
    # Accesses the current user from the session.  Set it to :false if login fails
    # so that future calls do not hit the database.
    def current_user
      @current_user ||= (login_from_token || login_from_basic_auth || :false)
      @current_user
    end
    
    # Store the given user in the session.
    def current_user=(new_user)
      session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.login
      session[:f1token] = new_user.f1token if new_user
      @current_user = new_user
    end
    
    # Check if the user is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_user.login != "bob"
    #  end
    def authorized?
      logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end

    # NOTE: This is completely overridden in appliaciton_controller.rb
    # TODO: combine the one in applicaiton_controller with this one
    #
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      puts "access denied; format=#{format}"
      respond_to do |accepts|
        accepts.html do
          puts "accepts html"
          if logged_in?
            puts 'logged in'
            access_unauthorized('You are not authorized for this action')
          else
            store_location
            redirect_to login_path
          end
        end
        accepts.xml do
          access_unauthorized
        end
        accepts.kml do
          access_unauthorized
        end
        accepts.atom do
          access_unauthorized
        end
        accepts.rss do
          access_unauthorized
        end
        accepts.json do
          access_unauthorized
        end
      end
      false
    end  

    def access_unauthorized(text = "Could't authenticate you")
      headers["Status"]           = "Unauthorized"
      headers["WWW-Authenticate"] = %(Basic realm="Web Password")
      render :text => text, :status => '401 Unauthorized'
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.url
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

    # Called from #current_user. First attempt to login by the user id stored in the session.
    # def login_from_session
    #   u = User.find_by_login(session[:user]) if session[:user]
    #   if (u && session[:f1token])
    #     if (u.f1token != session[:f1token])
    #       u.f1token = session[:f1token]
    #       u.save!
    #     end
    #   end
    #   self.current_user = u
    # rescue ActiveResource::UnauthorizedAccess
    #   return nil
    # end
    
    # Called from #current_user. First attempt to login by the user id stored in the session.
    def login_from_session
      if (session[:user])
        u = User.find_by_login(session[:user])
        return nil if u.nil?
        puts "logged in from session #{u.inspect}"
        return u
        #u.f1token = session[:f1token] if session[:f1token]
        #u.save unless u.nil?
        #self.current_user = u unless u.nil?
      end
    rescue ActiveResource::UnauthorizedAccess
      return nil
    end
    

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      username, passwd = get_auth_data
      self.current_user = User.authenticate(username, passwd) if username && passwd
    end

    # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie      
      # return nil   #disabled for now
      user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        user.remember_me
        cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
        self.current_user = user
      end
    end
    
    # tries to log in from a session token if it exists
    def login_from_token
      self.current_user = User.authenticate_by_token(session[:user], session[:f1token]) if (session[:user] && session[:f1token])
    end
    
  private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
    end
end
