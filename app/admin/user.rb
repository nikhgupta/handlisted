ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation
  actions :all, except: [:destroy]

  index do
    selectable_column
    id_column
    column(:name, sortable: :name) do |user|
      content_tag :div, class: "card" do
        concat(
          content_tag(:div, class: :image) do
            link_to present(user).avatar_tag(width: 50), profile_path(user), target: "_blank"
          end
        )
        concat(
          content_tag(:div, class: :info) do
            concat(content_tag :span, "@" + user.username, style: "font-weight: bold")
            concat(tag :br)
            concat(content_tag :span, user.name)
            concat(tag :br)
            concat(content_tag :span, user.email)
          end
        )
      end
    end
    column(:badges) do |user|
      content_tag :div do
        if user.admin?
          concat(content_tag :a, fa_icon("bolt") + " admin", class: "badge special")
          concat " "
        end
        concat present(user).badge_list
      end
    end
    column :found, :found_products_count
    column(:likes){|user| user.liking.count }
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
