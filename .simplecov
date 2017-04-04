# simplecov configuration
if defined?(Spring)
  message  = "Coverage tests while Spring is running are unreliable.\n"
  message += "Please, try again with Spring disabled.\n"
  message += "Try running: bin/coverage"
  puts "\\033[33m#{message}\\033[0m"
elsif SimpleCov.running
  puts "\\033[37mSimpleCov is already running..\\033[0m\n"
else
  puts "\\033[35mLoading SimpleCov for coverage testing..\\033[0m\n"
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

  coverage_dir = ENV['CI'] ? ENV['CIRCLE_ARTIFACTS'] : "tmp"
  SimpleCov.coverage_dir "#{coverage_dir}/coverage"
end unless ENV['COVERAGE'].to_s.strip.empty?
