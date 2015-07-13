module ApplicationHelper
  def image_logo_tag options = {}
    "<h3 class='logo brand'>Curated Shop</h3>".html_safe
    # image_tag:logo, { title: "CuratedShop" }.merge(options)
  end

  def fa_icon(name, options = {})
    options[:class] = "fa fa-#{name} #{options[:class]}"
    "<i #{options.map{|k,v| "#{k}=\"#{v}\""}.join(" ")}'></i>".html_safe
  end

  def fa_omniauth_button(provider, options = {})
    text = "<span>#{fa_icon(provider)}</span>#{options.fetch(:name, provider.to_s.titleize)}"
    options[:class] = "button btn-social #{provider} btn-block #{options[:class]}"
    link_to text.html_safe, user_omniauth_authorize_path(provider.to_s.underscore), options
  end

  def fa_omniauth_icon provider, options = {}
    provider = provider.to_s.humanize.parameterize
    icon = fa_icon "#{provider}-square", title: provider.titleize, class: "fa-#{options.fetch(:size, 2)}x fa-#{provider}-colored", style: options[:style]
    link_to icon.html_safe, user_omniauth_authorize_path(provider.to_s.underscore)
  end
end
