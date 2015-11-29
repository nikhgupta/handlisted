class UserPresenter < ApplicationPresenter
  def name
    model.name || model.email
  end

  def username_link
    h.link_to("@#{model.username}", h.profile_path(model), class: "card-on-hover")
  end

  def avatar_link
    link_avatar_to h.profile_path(model), class: "card-on-hover"
  end

  def link_avatar_to(*args)
    h.link_to(avatar_tag(class: "img-responsive"), *args)
  end

  # NOTE: Obtrusive JS is present, since that is the only reliable way to ensure
  # broken avatar images are not present even when avatars are loaded via AJAX.
  # TODO: use retina
  def avatar_tag(options = {})
    klass = "#{options.delete(:class)} media-object avatar"
    on_error = "this.onerror=null;this.src='#{default_avatar}';"
    h.image_tag avatar, { alt: name, class: klass, onError: on_error }.merge(options)
  end

  def profile_link(text, *args)
    h.link_to(text, h.profile_path(model), *args)
  end

  def avatar
    model.image.present? ? model.image : default_avatar
  end

  def badge_list
    model.badges.map{|badge| h.badge_tag_for(badge) }.join(" ").html_safe
  end

private

  def default_avatar
    h.image_path "avatars/missing.jpg"
  end
end
