if ENV['SLEEP'].present?
  puts "Included SleepTimer to find bottlenecks..."
  puts "It is recommended to run RSpec in documentation format."

  RSpec.configure do |config|
    config.before(:suite) do
      $sleep = { normal: 0, traffic: 0, capybara: 0, overall: 0 }
    end

    config.after(:suite) do
      puts
      puts "----------------"
      puts "Sleep Statistics"
      $sleep.each do |key, value|
        puts "Time spent sleeping inside #{"%8s" % key} routine: #{"%02.2f" % value} seconds" if value > 0
      end
      puts "----------------"
    end
  end

  class Object
    def sleep(*args)
      lines = caller.select{|a| a =~ /\/spec\// }
      lines.map!{|a| a.gsub(Regexp.new(Rails.root.to_s), '.')}
      is_normal = lines && lines.any? && args[0] >= 0.1 && ENV['SLEEP'].present? && ENV['SLEEP'] != 'capybara' && ENV['SLEEP'] != 'traffic'
      $sleep[:overall] += args[0] if lines && lines.any?
      $sleep[:normal]  += args[0] if is_normal
      puts "sleeping for #{args} seconds:\n#{lines.join("\n")}\n\n" if is_normal
      super
    end
  end

  if ENV['SLEEP'] =~ /^traffic|all$/
    module DriverAgnosticHelpers
      def wait_for_traffic
        return if rack_test?
        start = Time.now
        line = caller.detect{|a| a =~ /\/spec\/features\// }
        line = line.gsub(Regexp.new(Rails.root.to_s), '.')
        while page.driver.network_traffic.collect(&:response_parts).any?(&:empty?)
          sleep 0.05
          $sleep[:traffic] += 0.05
          puts "waited #{"%0.2f" % (Time.now - start)} seconds for traffic:  #{line}" # if counter % 2 == 0
        end
      end
    end
  end
end

# Monkey patching isn't elegant, but helps us to find unnecessary calls to
# Capybara synchronization timeouts.
module Capybara
  module Node
    class Base
      def synchronize(seconds=Capybara.default_wait_time, options = {})
        start_time = Time.now

        if session.synchronized
          yield
        else
          session.synchronized = true
          begin
            yield
          rescue => e
            session.raise_server_error!
            raise e unless driver.wait?
            raise e unless catch_error?(e, options[:errors])
            if (Time.now - start_time) >= seconds
              raise e.class, e.message + "\nAdditionally, Capybara's timeout limit was reached here."
            end
            sleep(0.05)
            if ENV['SLEEP'] =~ /^capybara|all$/
              $sleep[:capybara] += 0.05
              puts "waited #{"%0.2f" % (Time.now - start_time)} seconds for capybara: #{e.message}" # if counter % 2 == 0
            end
            raise Capybara::FrozenInTime, "time appears to be frozen, Capybara does not work with libraries which freeze time, consider using time travelling instead" if Time.now == start_time
            reload if Capybara.automatic_reload
            retry
          ensure
            session.synchronized = false
          end
        end
      end
    end
  end
end
