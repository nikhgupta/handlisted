class UserPresenter < ApplicationPresenter
  def name
    model.name || model.email
  end

  def link_avatar_to(*args)
    h.link_to(h.image_tag(avatar, class: "img-responsive", alt: name), *args)
  end

private

  def avatar
    model.image.present? ? model.image : default_avatar
  end

  def default_avatar
    h.image_path "absolute-admin/avatars/3.jpg"
  end
end
