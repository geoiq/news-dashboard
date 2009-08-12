set :stage, :staging

set :user, "wrapper"
set :group, "wrapper"

set :hostname, "codiv.dev.fortiusone.local"
role :app, hostname
role :web, hostname
role :db,  hostname, :primary => true 

set :platform, "public"

set :scm, :git
set :repository, "git@babylon:geocommons.git"
set :base_path, "/fortiusone/live"

# set :deploy_via, :remote_cache
set :deploy_via, :copy
set :copy_cache, true
#set :copy_strategy, :export
set :keep_releases, 2