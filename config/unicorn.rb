app_dir = File.expand_path("../..", __FILE__)
tmp_dir = "#{app_dir}/tmp"

working_directory app_dir
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)

pid "#{tmp_dir}/pids/unicorn.pid"

if ENV['RAILS_ENV'] == 'production' || ENV['RACK_ENV'] == 'production'
  timeout 30
  preload_app true
  stderr_path "#{app_dir}/log/unicorn.log"
  stdout_path "#{app_dir}/log/unicorn.log"
  listen "#{tmp_dir}/sockets/unicorn.sock", backlog: 64
else
  timeout 1800
end

GC.respond_to?(:copy_on_write_friendly=) && GC.copy_on_write_friendly = true

before_fork do |server, worker|
  server.logger.info("worker=#{worker.nr} spawning in #{Dir.pwd}")

  # graceful shutdown.
  old_pid_file = "#{tmp_dir}/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid_file) && server.pid != old_pid_file
    begin
      old_pid = File.read(old_pid_file).to_i
      server.logger.info("sending QUIT to #{old_pid}")
      # we're killing old unicorn master right there
      Process.kill("QUIT", old_pid)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
