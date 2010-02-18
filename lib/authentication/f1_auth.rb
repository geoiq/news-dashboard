module F1Auth
  
  def self.everyman_group
    return (Configuration.require_login? ? 0 : -1)
  end
  
  module ViewExtensions
    # def link_to(*args, &block)
    #   @page_links ||= []
    #   @page_links << super(*args)
    #   environment = args[2] || {}
    #   begin
    #     path_parts = ActionController::Routing::Routes.recognize_path(url_for(args[1]), environment) 
    #   rescue Exception => e
    #     logger.debug("Could not recognize path for #{args.inspect}.\n Error was #{e.inspect}")
    #     return nil
    #   end
    #   options = sanitize_path_parts(path_parts)
    #   return (has_permission?(options) ? super(*args) : '')
    # end  
  
    def check_permissions
      has_perm = has_permission?(:controller => params[:controller], :action => params[:action], :id => params[:id])
      access_denied unless has_perm
    end

    def get_actions(controller_obj)
      controller_obj.methods - ApplicationController.methods - Object.methods - ApplicationController.new.methods
    end
  
    def has_permission?(options = {})
      if logged_in?
        #permission_list(options).length > 0
        Permission.count(:conditions => get_conditions(current_user.get_all_group_ids, options)) > 0
      else
        Permission.count(:conditions => get_conditions([-1], options)) > 0
      end
    end
    
    def permission_list(options = {})
      #return Permission.find(:all, :conditions => get_conditions(current_user.get_all_group_ids, options))
      current_permissions.select { |p| 
        (p.controller == "all" && p.action == "all") ||
        (p.controller == "all" && p.action == options[:action]) ||
        (p.controller == options[:controller] && p.action == "all") ||
        (p.controller == options[:controller] && p.action == options[:action]) ||
        (p.controller == options[:controller] && p.action == "all" && p.id == options[:id]) ||
        (p.controller == options[:controller] && p.action == options[:action] && p.id == options[:id])
      }
    end
  
    # Returns true if either the user is an administrator, or if the user has permissions either to delete that entry or all permissions on that id
    def has_admin_permissions_for_page?(options = {})
      return true if current_user.admin?
      current_permissions.select { |p|
        p.controller = options[:controller] && (p.action == "all" || p.action == "delete") && p.id = options[:id]
      }.length > 0
    end
  
    private
  
    def current_permissions
      @current_user_permissions = get_permissions
    end
  
    def get_permissions
      return [] unless logged_in?
      conditions = get_conditions(current_user.get_all_group_ids, params)
      Permission.find(:all, :conditions => conditions)
      #Permission.find(:all, :conditions => {:group_id => current_user.get_all_group_ids})
    end

    # get conditions for a find(:all)
    def get_conditions(groups, options = {})
      options = options.clone # Often params are directly passed here... and this function can mess 'em up
      options[:id] = nil unless options[:id] =~ /^\d+$/
      id_select = options[:id].blank? ? "IS NULL" : "= :id"          
      conditions = [%Q{
        group_id IN (:groups) AND (
          (controller = 'all' AND action = 'all') OR
          (controller = :controller AND action = 'all' AND item_id #{id_select}) OR
          (controller = :controller AND action = :action) OR
          (controller = :controller AND action = :action AND item_id #{id_select} ) )},
        { :groups => groups, :controller => options[:controller], :action => options[:action], :id => options[:id] }]    
      return conditions
    end
  
    # TODO: This is not robust or railsy... but it works for now... robustify!
    def sanitize_path_parts(options = {})
      if (options[:action] && options[:action].match(/^\d*$/))
        id = options[:action]
        action = options[:id]
        options[:action] = action
        options[:id] = id
      end
      options[:action] ||= (options[:id] ? "show" : "index")
      options
    end
  end
  
  module ControllerExtensions
        
    def admin
      conditions = { :controller => params[:controller], :item_id => params[:id] }
      @item = instance_variable_get("@#{self.controller_name.singularize}")
      @user = current_user
      #@groups = Group.find(:all, :conditions => { :user_id => nil })
      @groups = current_user.groups
      #Group.find(:all, :conditions => { :user_id => nil, :group_id => current_user.get_all_group_ids })
      #raise "GROUPS! #{@groups.inspect}"
      @permissions = Permission.find(:all, :conditions => conditions)
      render :file => "#{RAILS_ROOT}/app/views/f1/layouts/item_admin.html.erb", :layout => 'application'
    end 
  end

  module DefaultPermission

    def self.setup_default_permissions
      permissions_hash = JSON.parse(File.read("#{RAILS_ROOT}/config/base_permissions.json"))
      everyman_group = Configuration.everyman_group
      permissions_hash["base"]["permissions"].each do |perm|
        conditions = "action = '#{perm['action']}' AND controller = '#{perm['controller']}'"
        conditions += " AND item_id = '#{perm['item_id']}" unless perm['item_id'].blank?
        # First wipe any old permissions
        Permission.destroy_all(conditions)
        # Now create permissions based on the everyman group
        group_id = (perm['group_id'] || everyman_group)
        Permission.create(:action => perm['action'], :controller => perm['controller'], :item_id => perm['item_id'], :group_id => group_id)
      end
    end

  end
end
