module RSpecCustomMatchersForCuratedShop
  class HaveBadge
    def initialize(*expected)
      name, level = [expected].flatten
      @badge = Merit::Badge.find_by_name_and_level(name, level)
    end

    def matches?(page_or_model)
      @page_or_model = page_or_model
      is_page? ? page_has_badge? : model_has_badge?
    end

    def failure_message
      is_page? ? failure_message_when_page : failure_message_when_model
    end

    def failure_message_when_negated
      @negated = true
      failure_message
    end

    def special
      @special = true
      self
    end

    def unique
      @unique = true
      self
    end

    def with_difficulty(diff)
      @difficulty = diff
      self
    end

    private

    def is_page?
      @page_or_model.is_a?(Capybara::Session)
    end

    def badge_name
      @badge.name.humanize.titleize + (@badge.level ? " L#{@badge.level}" : "")
    end

    def page_has_badge?
      valid = true
      badge = @page_or_model.all("a.badge", text: badge_name).first

      valid &&= badge.present?
      valid &&= badge[:title] == @badge.description
      valid &&= badge[:class].include?("special")   if @special
      valid &&= badge.has_selector?("i.fa.fa-bolt") if @unique
      valid &&= badge[:class].include?(@difficulty) if @difficulty.present?
      valid
    end

    def model_has_badge?
      @page_or_model.reload.badges.include?(@badge)
    end

    def failure_message_when_page
      attributes  = []
      attributes << "unique"   if @unique
      attributes << "special"  if @special
      attributes << @difficulty if @difficulty.present?
      "expected #{@page_or_model.current_path}#{@negated ? " not" : ""} to have #{attributes.join(" ")} badge #{badge_name}"
    end

    def failure_message_when_model
      "expected #{@page_or_model.class.name} #{@page_or_model}#{@negated ? " not" : ""} to have badge #{badge_name}"
    end
  end

  def have_badge(*expected)
    HaveBadge.new(*expected)
  end
end
