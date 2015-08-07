module DriverAgnosticHelpers
  def click_on_button(*args)
    return click_on(*args) if rack_test?
    find_button(*args).trigger('click')
    wait_for_traffic
  end

  def click_on_selector(*args)
    return find(*args).click if rack_test?
    find(*args).trigger(:click)
    wait_for_traffic
  end

  def wait_for_traffic
    return if rack_test?
    sleep 0.05 while page.driver.network_traffic.collect(&:response_parts).any?(&:empty?)
  end

  def rack_test?
    Capybara.current_driver == :rack_test
  end

  def js_test?
    Capybara.current_driver == :poltergeist
  end
end
