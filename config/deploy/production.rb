set :user,  "root"
set :group, "wheel"
ssh_options[:keys] = [File.join(ENV["HOME"], ".ec2-geocommons", "id_rsa")] 

# set(:hostname) { Capistrano::CLI.ui.ask("\n>> Hostname (e.g. ec2-75-101-250-183.compute-1.amazonaws.com): ") }
set(:hostname) { ENV['DOMAIN'] || Capistrano::CLI.ui.ask("\n>> Domain Name (e.g. customer.geoappliance.com): ") }


role :app, hostname
role :web, hostname
role :db,  hostname, :primary => true 
set :deploy_via, :copy

after "deploy:symlink", "deploy:set_permissions"
namespace :deploy do
  task :set_permissions do
    run "chown -R nobody:nobody #{current_path}/"    
  end
  
  task :start do
    run "service httpd restart"
  end
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

end

