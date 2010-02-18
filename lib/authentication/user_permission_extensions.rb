module UserAuthenticationExtensions
  ADMIN_GROUP = 1
  
  # Recursively return all the groups of an object
  def get_all_groups
    grps = []
    grps += self.groups
    grps.each { |g| grps += g.get_all_groups }
    return grps.compact.uniq
  end
  
  def get_all_group_ids
    return self.get_all_groups.map(&:id)
  end
  
  def admin?
    #return (self.get_all_group_ids.include? ADMIN_GROUP) # hardcoded for now
    
    # TODO: Return to the actual permissions check!
    return self.admin
  end
  
  def user_group
    Group.find(:all, :conditions => { :name => self.login, :id => self.get_all_group_ids }).first
  end

  # Remove object from group
  # Returns object groups
  def remove_from_group(group)
    if (group.class == Group)
      g = group
    elsif (group.class == Fixnum)
      g = Group.find(group)
    end
    raise "Invalid group" unless g
    raise "object is not in group" unless self.groups.include?(g)
    raise "cannot remove a middle level group" if (self.class == Group && !Grouping.find_by_group_id(self.id).nil?)
    self.groups.delete(g)
  end
  
  protected
  
  def get_groups_recursively
  end
      
end
