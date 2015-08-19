module ApplicationHelper
  def present(object, klass=nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

  def current_user
    present(super) if super
  end

  def path_is?(path)
    request.path == path
  end

  def home_page?
    request.path == root_path
  end

  # TODO: link tp image logo
  def link_logo_to(path, options = {})
    # html = image_tag("logo.png", class: "img-responsive w250")
    html = "<span><strong>Curated</strong>Shop</span>"
    link_to html.html_safe, path, options
  end

  def fa_icon(name, options = {})
    options[:class] = "fa fa-#{name} #{options[:class]}"
    "<i #{options.map{|k,v| "#{k}=\"#{v}\""}.join(" ")}'></i>".html_safe
  end

  def oauth_icon_for provider, options = {}
    provider = provider.to_s.titleize
    options  = { title: provider }.merge(options)
    size     = "fa-#{options.delete(:size) || "2x"}"
    options[:class] = "#{options[:class]} #{size} fa-#{provider.parameterize}-colored"
    fa_icon "#{provider.parameterize}-square", options
  end

  def oauth_link_to provider, html, options = {}
    link = omniauth_authorize_path(:user, provider.to_s.underscore)
    link_to html.html_safe, link, options
  end
end
