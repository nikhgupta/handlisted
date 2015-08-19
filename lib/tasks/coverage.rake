namespace :metrics do
  # desc 'Run RSpec for full application while generating coverage report'
  # task coverage: :environment do
  #   puts "Running RSpec and generating Code coverage.."
  #   path = Rails.root.join("tmp", "simplecov", "output")
  #   system "rm -rf #{path}"
  #   exec "COVERAGE=1 bin/rspec --profile=10 --format=documentation; open #{path}/index.html"
  # end

  # desc 'Run Complete analysis of Code..'
  # task all: :environment do
  #   # tools: rspec coverage, metric_fu, brakeman, bundler-audit
  #   commands = <<-BASH
  #     echo 'Switching to Rails directory.........\\c'
  #     cd #{Rails.root}
  #     echo '... done!'

  #     echo 'Housekeeping.........................\\c'
  #     rbenv rehash
  #     rake log:clear
  #     rake tmp:clear
  #     rake tmp:create &>/dev/null
  #     mkdir -p ./tmp/brakeman ./tmp/fasterer ./tmp/rspec
  #     echo '... done!'

  #     echo 'Running tests........................\\c'
  #     COVERAGE=1 bin/rspec --format=html > ./tmp/rspec/index.html
  #     echo '... done!'

  #     echo 'Detecting security vulnerabilities...\\c'
  #     brakeman -o ./tmp/brakeman/index.html &>/dev/null
  #     bundle-audit update &>/dev/null
  #     bundle-audit check 1>/dev/null
  #     echo '... done!'

  #     echo 'Checking code quality................\\c'
  #     rubycritic app lib &>/dev/null
  #     metric_fu --no-open &>/dev/null
  #     fasterer > ./tmp/fasterer/index.html
  #     echo '... done!'

  #     echo 'Opening your results.................\\c'
  #     open ./tmp/fasterer/index.html
  #     open ./tmp/brakeman/index.html
  #     open ./tmp/rubycritic/overview.html
  #     open ./tmp/metric_fu/output/index.html
  #     open ./tmp/simplecov/output/index.html
  #     open ./tmp/rspec/index.html
  #     echo '... done!'

  #     echo
  #     echo '-- Notes: ------------------------------------'
  #     rake notes
  #   BASH

  #   commands = commands.split("\n").map(&:strip).reject(&:blank?).join(" && \n")
  #   exec "TIMEFORMAT=$'\nReports generated in %2lR seconds.'; time { #{commands}; }"
  # end
end
