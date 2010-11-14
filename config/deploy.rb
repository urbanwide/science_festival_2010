require 'capistrano/ext/multistage'

set :stages, %w(production)
set :default_stage, "staging"

set :application, "science-festival-10"
set :use_sudo, false

default_run_options[:pty] = true
set :repository, "git@github.com:urbanwide/science_festival_10.git"
set :scm, "git"
set :scm_passphrase, "iranyme1"
set :user, "deploy"

role :app, "robl.org.uk"
role :web, "robl.org.uk"
role :db,  "robl.org.uk", :primary => true

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

