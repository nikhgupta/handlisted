namespace :rspec do
  desc 'Run RSpec for full application while generating coverage report'
  task coverage: :environment do
    puts "Running RSpec and generating Code coverage.."
    system "rm -rf #{Rails.root.join("coverage")}"
    exec "COVERAGE=1 bin/rspec --profile=10 --format=documentation; open coverage/index.html"
  end
end
