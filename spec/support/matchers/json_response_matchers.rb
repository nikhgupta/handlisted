RSpec::Matchers.define :have_json do |expected|
  # @expected = Hash[expected.map{|k,v| [k.to_s, v]}]
  match do |actual|
    @actual = JSON.parse actual.body
    expect(@actual).to include(expected)
  end

  diffable

  failure_message do |actual|
    "expected response to have json data: #{expected}"
  end

  failure_message_when_negated do |page|
    "expected response to not have json data: #{expected}"
  end

  description do
    "checks if the response includes some json data"
  end
end


