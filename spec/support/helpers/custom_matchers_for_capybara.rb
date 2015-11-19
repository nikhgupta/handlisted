# More matchers can be found in the `spec/support/matchers` directory, with
# custom matchers tailored to this application.
#
module CustomMatchersForCapybara
  Capybara.add_selector :linkhref do
    xpath do |href|
      XPath.descendant[XPath.attr(:href).contains(href)]
    end
  end
  def have_linkhref(href)
    Capybara::RSpecMatchers::HaveSelector.new(:linkhref, href)
  end
end
