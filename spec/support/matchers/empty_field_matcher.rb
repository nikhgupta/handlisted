RSpec::Matchers.define :have_empty_field do |selector, args|
  match do |page|
    expect(page).to have_field(selector, args)
    expect(page.find_field(selector, args).value).to be_blank # driver agnostic
  end

  failure_message do |page|
    "expected #{page.current_path} to have empty field: #{selector}"
  end

  failure_message_when_negated do |page|
    "expected #{page.current_path} to not have empty field: #{selector}"
  end

  description do
    "checks if the page has an empty field"
  end
end

