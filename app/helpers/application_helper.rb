module ApplicationHelper
  def present(object, klass=nil)
    unless object.is_a?(ApplicationPresenter)
      klass ||= "#{object.class}Presenter".constantize
      object = klass.new(object, self)
    end
    yield object if block_given?
    object
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

  def badge_tag_for(*args)
    badge = args.first.is_a?(Merit::Badge) ? args.first : Merit::Badge.find_by_name_and_level(*args)
    difficulty = badge.custom_fields["difficulty"]
    unique  = badge.custom_fields["unique"]  ? fa_icon('bolt') : ''
    special = unique.present? || badge.custom_fields["special"] ? 'special' : ''
    content_tag :a, class: "badge #{difficulty} #{special}", title: badge.description do
      unique + " " + badge.name.humanize.titleize
    end.html_safe
  end

  def image_or_html(image, html, options = {})
    if File.exist?(Rails.root.join("public", "images", image).to_s)
      image_tag image, options
    else
      html.html_safe
    end
  end

  def version_image_tag(version, options = {})
    image_or_html "#{version}.png", version.to_s.titleize, { class: "version", width: "40" }.merge(options)
  end

  def link_logo_to(path, options = {})
    image = "handlisted-text-logo#{"-dark-bg" if options.delete(:dark_bg)}.png"
    html  = "#{image_tag(image, class: "img-responsive logo", alt: "handlisted.in")}"
    html += "#{version_image_tag :beta, class: "version"}"
    link_to html.html_safe, path, options
  end

  def fa_icon(name, options = {})
    options[:class] = "fa fa-#{name} #{options[:class]}"
    "<i #{options.map{|k,v| "#{k}=\"#{v}\""}.join(" ")}></i>".html_safe
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

  def products_listing_for(products, kind: nil)
    locals = { products: products, kind: kind }
    render layout: "products/lists/default", locals: locals do
      yield if block_given?
    end
  end
end
