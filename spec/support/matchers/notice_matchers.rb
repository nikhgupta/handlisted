RSpec::Matchers.define :have_notice_with_text do |text|
  match do |page|
    expect(page).to have_css(".alert-success,.alert-info", text)
  end

  failure_message do |page|
    "expected #{page.current_path} to have notice with text: #{text}"
  end

  failure_message_when_negated do |page|
    "expected #{page.current_path} to not have notice with text: #{text}"
  end

  description do
    "checks if the page has a given notice"
  end
end

RSpec::Matchers.define :have_alert_with_text do |text|
  match do |page|
    expect(page).to have_css(".alert-danger", text)
  end

  failure_message do |page|
    "expected #{page.current_path} to have alert with text: #{text}"
  end

  failure_message_when_negated do |page|
    "expected #{page.current_path} to not have alert with text: #{text}"
  end

  description do
    "checks if the page has a given alert"
  end
end

RSpec::Matchers.define :have_warning_with_text do |text|
  match do |page|
    expect(page).to have_css(".alert-warning", text)
  end

  failure_message do |page|
    "expected #{page.current_path} to have warning with text: #{text}"
  end

  failure_message_when_negated do |page|
    "expected #{page.current_path} to not have warning with text: #{text}"
  end

  description do
    "checks if the page has a given warning"
  end
end
