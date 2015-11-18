# config valid only for current version of Capistrano
lock '3.4.0'

set :user, 'handlisted'
set :application, 'handlisted'
set :repo_url, 'git@github.com:nikhgupta/handlisted.in.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "$HOME/app"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push(".rbenv-vars")

# Default value for linked_dirs is []
set :linked_dirs,  fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

# Set ssh options
set :ssh_options, { forward_agent: true, auth_methods: %w(publickey) }
set :default_environment, { 'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH" }

# rbenv
set :rbenv_type, :user
set :rbenv_ruby, '2.2.3'

# rails
set :rails_env,  :production
set :keep_assets, 2

# foreman
set :shared_dir,  "#{fetch :deploy_to}/shared"
set :foreman_env, "#{fetch :shared_dir}/.rbenv-vars"
set :foreman_log, "#{fetch :shared_dir}/log/foreman.log"
set :foreman_bin, "$HOME/.rbenv/shims/foreman"

# rollbar
set :rollbar_token, ENV['ROLLBAR_ACCESS_TOKEN']
set :rollbar_env,   Proc.new { fetch :stage }
set :rollbar_role,  Proc.new { :app }

# rspec
set :test_log, "tmp/rspec/capistrano.log"
set :coverage, "tmp/simplecov/output/index.html"

namespace :foreman do
  desc "Export application processes as Systemd jobs"
  task :export do
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          sudo fetch(:foreman_bin), "export systemd /lib/systemd/system",
            "--app #{fetch :application} --user #{fetch :user}",
            "--env #{fetch :foreman_env}",
            "--log #{fetch :foreman_log}"
        end
      end
    end
  end

  desc "Start Application"
  task :start do
    on roles(:app) do
      sudo :systemctl, "daemon-reload"
      sudo :systemctl, :start, "#{fetch(:application)}.target"
    end
  end

  desc "Stop Application"
  task :stop do
    on roles(:app) do
      sudo :systemctl, "daemon-reload"
      sudo :systemctl, :stop, "#{fetch(:application)}.target"
    end
  end

  desc 'Restart Application'
  task :restart do
    on roles(:app) do
      sudo :systemctl, "daemon-reload"
      sudo :systemctl, :stop, "#{fetch(:application)}.target"
      sudo :systemctl, :start, "#{fetch(:application)}.target"
    end
  end
end

namespace :rspec do
  desc 'Run RSpec before deployment'
  task 'verify' do
    run_locally do
      target  = fetch :branch
      current = %x(git symbolic-ref HEAD 2>/dev/null | cut -d'/' -f 3).strip

      begin
        %x(git checkout #{target} &>/dev/null) if current != target
        info "Running tests (with coverage) on #{target}, please wait ..."

        if execute "COVERAGE=1 bundle exec rake > #{fetch :test_log} 2>&1"
          info "Tests passed. Coverage report: #{fetch :coverage}"
          execute "rm #{fetch :test_log}"
        else
          error "Tests failed. Run `cat #{fetch :test_log}` to see what went wrong."
          exit
        end
      ensure
        %x(git checkout #{current} &>/dev/null) if current != target
      end
    end
  end
end

namespace :deploy do
  before :starting,   "rspec:verify"
  after  :publishing, "foreman:export"
  after  :publishing, "foreman:restart"
  # after "deploy:finished", 'airbrake:deploy'
end
