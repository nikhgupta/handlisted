RSpec::Matchers.define :have_validation_error do |text|
  match do |page|
    expect(page).to have_css(".state-error", text: text)
  end

  match_when_negated do |page|
    expect(page).to have_no_css(".state-error", text: text)
  end

  failure_message do |page|
    "expected #{page.current_path} to have validation error with text: #{text}"
  end

  failure_message_when_negated do |page|
    "expected #{page.current_path} to not have validation error with text: #{text}"
  end

  description do
    "checks if the page has a given validation error"
  end
end
