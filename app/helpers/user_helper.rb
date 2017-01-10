module UserHelper
  def username_link_for(user)
    link_to "@#{user.username}", profile_path(user), class: "card-on-hover"
  end

  def badge_list_for(user)
    user.badges.map{|badge| badge_tag_for(badge) }.join(" ").html_safe
  end

  def avatar_link_for(user)
    default_avatar = image_path("avatars/missing.jpg")
    avatar         = user.image.present? ? user.image : default_avatar
    on_error       = "this.onerror=null;this.src='#{default_avatar}';"

    link_to image_tag(
      avatar, { alt: user.name, class: "img-responsive media-object avatar", onError: on_error }
    ), profile_path(user), class: "card-on-hover"
  end
end
