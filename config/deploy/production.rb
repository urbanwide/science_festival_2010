set :deploy_to, "/var/www/#{application}"

desc "Copy one of the sample database.yml files and update image locations"
task :after_update_code, :roles => :app do*,\.o$,\.obj$,\.info$,\.swp$,\.bak$,\~$
  run "cp #{release_path}/config/database.live.yml #{release_path}/config/database.yml"
end
