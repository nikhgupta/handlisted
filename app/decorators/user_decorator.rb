class UserDecorator < ApplicationDecorator
  decorates_association :products

  def name
    model.name || model.email
  end

  def link_avatar_to(*args)
    default = h.image_path "absolute-admin/avatars/3.jpg"
    image   = model.image.present? ? model.image : default
    image   = h.image_tag(image, class: "img-responsive", alt: name)
    h.link_to(image, *args)
  end
end
