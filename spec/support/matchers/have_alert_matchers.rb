module RSpecCustomMatchersForCuratedShop
  class HaveAlert
    def initialize(expected)
      @expected = expected
    end

    def matches?(page)
      @page, @type = page, [@type].flatten
      klass  = ".alert"
      klass += ".pastel" if @pastel
      klass += ".alert-#{@type.join(",.alert-")}" if @type.any?

      verify klass, text: @expected
    end

    def failure_message
      message  = "expected #{@page.current_path} page to #{self.class.name.demodulize.titleize.downcase}"
      message += " (as #{@type.join(" or ")})" if @type.any?
      message += " (as pastel)" if @pastel
      message += " with text: #{@expected}"
      message += "\n#{all_alerts_message}"
      message
    end

    def failure_message_when_negated
      message  = "expected #{@page.current_path} page to not #{self.class.name.demodulize.titleize.downcase}"
      message += " (as #{@type.join(" or ")})" if @type.any?
      message += " (as pastel)" if @pastel
      message += " with text: #{@expected}"
      message += "\n#{all_alerts_message}"
      message
    end

    def as_success
      @type = :success
      self
    end

    def as_info
      @type = :info
      self
    end

    def as_notice
      @type = [:info, :success]
      self
    end

    def as_error
      @type = :danger
      self
    end

    def as_warning
      @type = :warning
      self
    end

    def as_pastel
      @pastel = true
      self
    end

    protected

    def verify(css_klass, options = {})
      @page.has_css?(css_klass, options)
    end

    private

    def all_alerts_message
      alerts = @page.all(".alert")
      return "Found no alerts on this page." if alerts.empty?

      message = "For reference, I found the following alerts on this page:\n"
      alerts.each do |alert|
        message += " - #{alert[:class].split(' ').join('.')}: #{alert.text}"
      end
      message
    end
  end

  class HaveNoAlert < HaveAlert
    protected
    def verify(css_klass, options = {})
      @page.has_no_css?(css_klass, options)
    end
  end

  def have_alert(expected)
    HaveAlert.new(expected)
  end

  def have_no_alert(expected)
    HaveNoAlert.new(expected)
  end
end
