set :user,  "root"
set :group, "wheel"
ssh_options[:keys] = [File.join(ENV["HOME"], ".ec2-geocommons", "id_rsa")] 

# set(:hostname) { Capistrano::CLI.ui.ask("\n>> Hostname (e.g. ec2-75-101-250-183.compute-1.amazonaws.com): ") }
set(:hostname) { Capistrano::CLI.ui.ask("\n>> Domain Name (e.g. customer.geoappliance.com): ") }

role :app, hostname
role :web, hostname
role :db,  hostname, :primary => true 
set :deploy_via, :copy

set :base_path, "/fortiusone/live"

def with_user(new_user, new_pass, &block)
  old_user, old_pass = user, password
  set :user, new_user
  set :password, new_pass
  close_sessions
  yield
  set :user, old_user
  set :password, old_pass
  close_sessions
end

def close_sessions
  sessions.values.each { |session| session.close }
  sessions.clear
end

require 'erb'
before "deploy:setup", "db:config"
after "deploy:update_code", "db:symlink" 
namespace :db do
  desc "Create database.yml in shared/config" 
  task :config do
    database_configuration = ERB.new <<-EOF
production:
  adapter: postgresql
  port: 5432
  username: #{application}
  password: #{application}
  database: #{application}
EOF

    platform_configuration = ERB.new <<-EOF
production:
    url: http://#{hostname}
    finder: http://finder.#{hostname}
    maker: http://maker.#{hostname}
    scratch: file:/fortiusone/live/scratch
EOF

    run "mkdir -p #{deploy_to}/#{shared_dir}/config" 
    put database_configuration.result, "#{deploy_to}/#{shared_dir}/config/database.yml" 
    put platform_configuration.result, "#{deploy_to}/#{shared_dir}/config/platform.yml" 
  end
  
  desc "Make symlink for database yaml" 
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
    run "ln -nfs #{shared_path}/config/platform.yml #{release_path}/config/platform.yml" 
    run "chown -R nobody:nobody #{release_path}/public"
  end  
end

# desc "Link in the production database.yml" 
# task :after_update_code do
#   run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml" 
# end

before "deploy:setup", "deploy:setup_server"
before "deploy:setup", "deploy:setup_database"
after "deploy:symlink", "deploy:set_permissions"
namespace :deploy do
  task :set_permissions do
    run "chown -R nobody:nobody #{current_path}/"    
  end
  
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  task :setup_server do
    
    passenger_config = ERB.new <<-EOF    
<VirtualHost *:80>
    ServerName #{application}.#{hostname}
    DocumentRoot #{current_path}/public
</VirtualHost>
EOF
    put passenger_config.result, "/etc/httpd/sites/#{application}.conf" 
    # todo - get the scratch directory from the yaml file.
    run "/etc/init.d/httpd graceful"
    
    # Scratch directory for files
    db_config = YAML.load_file("config/platform.yml")
    scratch = db_config["production"]["scratch"]
    run "mkdir -p #{scratch} #{deploy_to} #{deploy_to}/releases #{deploy_to}/shared/system #{deploy_to}/shared/log #{deploy_to}/shared/pids"
    run "chown -R nobody:nobody #{scratch} #{deploy_to} #{deploy_to}/releases #{deploy_to}/shared/system #{deploy_to}/shared/log #{deploy_to}/shared/pids"
    
  end

  task :setup_database do
    db_config = YAML.load_file("config/database.yml")
    user = db_config["production"]["username"]
    pass = db_config["production"]["password"]
    db = db_config["production"]["database"]
    status = sudo "createuser -SlqRD #{user}; echo $?", :as => "postgres"
    puts "WARNING: Got Bad Exit Status.  Maybe database user #{user} already exists?" if(status.to_i != 0)
    sudo "psql -c \"ALTER USER #{user} WITH PASSWORD '#{pass}';\" ", :as => "postgres"
    sudo "psql -c \"CREATE DATABASE #{db}; GRANT ALL PRIVILEGES ON DATABASE #{db} TO #{user};\" ", 
    :as => "postgres"

  end
  task :drop_database do
    db_config = YAML.load_file("config/database.yml")
    user = db_config["production"]["username"]
    db = db_config["production"]["database"]
    status = sudo "dropdb #{db}", :as => "postgres"
    status = sudo "dropuser #{user}", :as => "postgres"
  end  
end

desc "Restart Application"
task :restart, :roles => :app do
  run "touch #{current_path}/tmp/restart.txt"
end
  
