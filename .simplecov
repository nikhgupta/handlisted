# simplecov configuration
if defined?(Spring)
  message  = "Coverage tests while Spring is running are unreliable.\n"
  message += "Please, try again with Spring disabled.\n"
  puts "\e[33m#{message}\e[0m"
elsif SimpleCov.running
  puts "\e[37mSimpleCov is already running..\e[0m\n"
else
  puts "\e[35mLoading SimpleCov for coverage testing..\e[0m\n"
  SimpleCov.start 'rails' do
    add_filter 'vendor/'
    add_filter 'app/admin'  # for now

    # add_group 'Admin',      'app/admin'
    add_group 'Presenters', 'app/presenters'
    add_group 'Extractors', 'app/extractors'
    add_group 'Services',   'app/services'
    add_group 'Sidekiq',    'app/jobs'
  end
  SimpleCov.command_name 'RSpec'
  SimpleCov.coverage_dir 'tmp/simplecov/output'
end
