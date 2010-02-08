module NewsUserExtensions
  def atlases
    return Atlas.find_all_by_user_login(self.login)
  end
  
end