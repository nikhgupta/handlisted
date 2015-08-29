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
    h.link_to(h.image_tag(avatar, class: "img-responsive", alt: name), *args)
  end

  def avatar
    model.image.present? ? model.image : default_avatar
  end

  def avatar_tag(options = {})
    klass = "#{options.delete(:class)} media-object avatar"
    h.image_tag avatar, { alt: name, class: klass }.merge(options)
  end

  def profile_link(text, *args)
    h.link_to(text, h.profile_path(model), *args)
  end

private

  def default_avatar
    h.image_path "avatars/missing.jpg"
  end
end
