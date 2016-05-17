ActiveAdmin.register Product do
  permit_params :founder_id, :merchant_id, :brand_id, :category_id, :images,
    :pid, :slug, :original_name, :url, :name, :note, :features, :description,
    :price_cents, :price_currency, :marked_price_cents, :marked_price_currency, :available,
    :prioritized, :average_rating, :ratings_count, :lock_version, :url_hash

  actions :all, except: [:new, :create]
  index do
    selectable_column
    id_column
    column(:name, sortable: :name) do |product|
      content_tag :div, class: "card" do
        concat(
          content_tag(:div, class: :image) do
            link_to present(product).cover_image_tag(height: 50, alt: ''), product_path(product), target: "_blank"
          end
        )
        concat(
          content_tag(:div, class: :info) do
            concat(link_to product.original_name, product.url, style: "font-weight: bold")
            concat(tag :br)
            if product.brand.present?
              concat " by "
              concat(content_tag :span, product.brand.name)
            end
            concat " on "
            concat(content_tag :span, product.merchant.name.titleize)
          end
        )
      end
    end
    column(:price, sortable: :price){|product| present(product).price}
    column :category
    column(:likes){|product| product.likers.count}
    actions
  end
end
