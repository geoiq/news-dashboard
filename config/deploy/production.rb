set :user,  "root"
set :group, "wheel"
ssh_options[:keys] = [File.join(ENV["HOME"], ".ec2-geocommons", "id_rsa")] 

# set(:hostname) { Capistrano::CLI.ui.ask("\n>> Hostname (e.g. ec2-75-101-250-183.compute-1.amazonaws.com): ") }
#set(:hostname) { Capistrano::CLI.ui.ask("\n>> Domain Name (e.g. customer.geoappliance.com): ") }
set :hostname, "news.geocommons.com"

role :app, hostname
role :web, hostname
role :db,  hostname, :primary => true 
set :deploy_via, :copy