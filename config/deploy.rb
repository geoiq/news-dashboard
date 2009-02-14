set :stages, %w(development staging appliance production ec2) 
set :default_stage, 'development' 
require 'capistrano/ext/multistage' 
ssh_options[:compression] = false

set :application, "news"

#set :repository_root, "svn+ssh://babylon/mnt/data/svn/gardens/#{application}" 
# set(:tag) { Capistrano::CLI.ui.ask("\n>> Tag to deploy, e.g. 'releases/1.3' (or press <enter> for trunk): ") }
# set(:repository) { (tag == "trunk" || tag.length == 0) ? "#{repository_root}/trunk" : "#{repository_root}/#{tag}" }
set :repository, "git@babylon:#{application}.git"
set :scm, "git"
set :runner, nil

set :deploy_to, "/fortiusone/live/apps/#{application}"
set :deploy_via, :copy




set :rake_cmd, (ENV['RAKE_CMD'] || nil)
task :rake_exec do
  if rake_cmd
    run "cd #{current_path} && /usr/bin/rake #{rake_cmd} RAILS_ENV=production"
  end
end
# 
# require 'erb'
# before "deploy:setup", :db
# after "deploy:update_code", "db:symlink" 
# namespace :db do
#   desc "Create database.yml in shared/config" 
#   task :default do
#     database_configuration = ERB.new <<-EOF
# production:
#   adapter: postgresql
#   port: 5432
#   username: #{application}
#   password: #{application}
#   database: #{application}
# EOF
# 
#     platform_configuration = ERB.new <<-EOF
# production:
#     url: http://#{hostname}
#     finder: http://finder.#{hostname}
#     maker: http://maker.#{hostname}
#     scratch: file:/fortiusone/live/scratch
# EOF
# 
#     run "mkdir -p #{deploy_to}/#{shared_dir}/config" 
#     put database_configuration.result, "#{deploy_to}/#{shared_dir}/config/database.yml" 
#     put platform_configuration.result, "#{deploy_to}/#{shared_dir}/config/platform.yml" 
#   end
#   
#   desc "Make symlink for database yaml" 
#   task :symlink do
#     run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
#     run "ln -nfs #{shared_path}/config/platform.yml #{release_path}/config/platform.yml" 
#   end  
# end
# 
# desc "Link in the production database.yml" 
# task :after_update_code do
#   run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml" 
# end
# 
# before "deploy:cold", "deploy:setup_server"
# before "deploy:cold", "deploy:setup_database"
# namespace :deploy do
#   task :restart do
#     run "touch #{current_path}/tmp/restart.txt"
#   end
#   
#   desc "Configures Passenger for the application"
#   task :setup_server do
#     passenger_config = ERB.new <<-EOF    
# <VirtualHost *:80>
#     ServerName #{application}.#{hostname}
#     DocumentRoot #{current_path}/public
# </VirtualHost>
# EOF
#     put passenger_config.result, "/etc/httpd/sites/#{application}.conf" 
#     # todo - get the scratch directory from the yaml file.
#     run "/etc/init.d/httpd graceful"    
#     run "mkdir -p #{deploy_to} #{deploy_to}/releases #{deploy_to}/shared/system #{deploy_to}/shared/log #{deploy_to}/shared/pids "    
#   end
# 
#   desc "Creates the database user and new database"
#   task :setup_database do
#     db_config = YAML.load_file("config/database.yml")
#     user = db_config["production"]["username"]
#     pass = db_config["production"]["password"]
#     db = db_config["production"]["database"]
#     status = sudo "createuser -SlqRD #{user}; echo $?", :as => "postgres"
#     puts "WARNING: Got Bad Exit Status.  Maybe database user #{user} already exists?" if(status.to_i != 0)
#     sudo "psql -c \"ALTER USER #{user} WITH PASSWORD '#{pass}';\" ", :as => "postgres"
#     sudo "psql -c \"CREATE DATABASE #{db}; GRANT ALL PRIVILEGES ON DATABASE #{db} TO #{user};\" ", :as => "postgres"
# 
#   end
#   
#   desc "Deletes the database and database user"
#   task :drop_database do
#     db_config = YAML.load_file("config/database.yml")
#     user = db_config["production"]["username"]
#     db = db_config["production"]["database"]
#     status = sudo "dropdb #{db}", :as => "postgres"
#     status = sudo "dropuser #{user}", :as => "postgres"
#   end  
# end
# 
#   