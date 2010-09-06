require 'bundler/capistrano'

set :application, 'scheduleitapp.com'

role :app, "scheduleitapp.com"
role :web, "scheduleitapp.com"
role :db,  "scheduleitapp.com", :primary => true
set :deploy_to, "/mnt/app/#{application}"

set :user, "www-data"
set :group, "www-data"
set :use_sudo, false
set :keep_releases, 5

set :rails_env, 'production'

# Source code
set :scm, :git
set :repository, "git@github.com:martincik/sscheduler.git"
set :branch, "master"
set :repository_cache, "git_cache"
set :deploy_via, :remote_cache
set :ssh_options, { :forward_agent => true }

default_run_options[:pty] = true

ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]

namespace :deploy do
  desc "Restarting mod_rails with restart.txt."
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails."
    task t, :roles => :app do ; end
  end
end

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && bundle exec whenever --update-crontab #{application}"
  end
end
after "deploy:symlink", "deploy:update_crontab"

task :copy_database_yml do
  run "cp #{shared_path}/config/database.yml #{release_path}/config"
end
after "deploy:update_code", :copy_database_yml

task :copy_shopify_yml do
  run "cp #{shared_path}/config/shopify.yml #{release_path}/config"
end
after "deploy:update_code", :copy_shopify_yml

