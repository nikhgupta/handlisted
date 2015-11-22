module EmailHelper
  def logo(tag, version)
    html  = "<span class='title'>hand<strong>listed</strong>.in</span>"
    html += " <span class='version'>#{version}</span>" if version
    content_tag(tag, class: "logo"){ link_to html.html_safe, root_url }
  end

  def br(width = 72)
    "-" * width
  end

  def salutation
    return if @resource[:name].blank?
    "Hello #{@resource.name},"
  end

  def welcome
    content_for(:welcome, true)
  end

  def feedback
    content_for(:feedback, true)
  end

  def title(message = nil)
    content_for(:title){ block_given? ? yield : message }
  end

  def footer
    content_for(:footer){ yield }
  end
end
