set :stage, :staging

set :user, "wrapper"
set :group, "wrapper"

set :hostname, "codiv.dev.fortiusone.local"
role :app, hostname
role :web, hostname
role :db,  hostname, :primary => true 

set :platform, "public"

set :scm, :git
set :repository, "git@babylon:news.git"
set :base_path, "/fortiusone/live"

# set :deploy_via, :remote_cache
set :deploy_via, :copy
set :copy_cache, true
#set :copy_strategy, :export
set :keep_releases, 2


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
    # run "chown -R nobody:nobody #{release_path}/public"
  end  
end

# desc "Link in the production database.yml" 
# task :after_update_code do
#   run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml" 
# end

# before "deploy:setup", "deploy:setup_server"
# before "deploy:setup", "db:create"
# after "deploy:symlink", "db:drop"
namespace :db do
  
  task :create do
    db_config = YAML.load_file("config/database.yml")
    user = db_config["production"]["username"]
    pass = db_config["production"]["password"]
    db = db_config["production"]["database"]
    status = sudo "createuser -SlqRD #{user}; echo $?", :as => "enterprisedb"
    puts "WARNING: Got Bad Exit Status.  Maybe database user #{user} already exists?" if(status.to_i != 0)
    sudo "psql -c \"ALTER USER #{user} WITH PASSWORD '#{pass}';\" ", :as => "enterprisedb"
    sudo "psql -c \"CREATE DATABASE #{db}; GRANT ALL PRIVILEGES ON DATABASE #{db} TO #{user};\" ", :as => "enterprisedb"
  end
  task :drop do
    db_config = YAML.load_file("config/database.yml")
    user = db_config["production"]["username"]
    db = db_config["production"]["database"]
    status = sudo "dropdb #{db}", :as => "postgres"
    status = sudo "dropuser #{user}", :as => "postgres"
  end  
end
