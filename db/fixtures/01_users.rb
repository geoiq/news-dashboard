User.seed(:login, :email) do |s|
  s.login = "admin"
  s.email = "admin@yourcompany.com"
  s.name = "Admin"
  s.password = "m4pp3r"
  s.password_confirmation = "m4pp3r"
end
