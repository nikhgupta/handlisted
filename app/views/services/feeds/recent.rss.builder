#encoding: UTF-8

xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title "Recent products on Handlisted.in"
    xml.author "Nikhil Gupta"
    xml.description "Shopping, Curated Shop"
    xml.link "http://handlisted.in"
    xml.language "en"

    @products.each do |product|
      xml.item do
        xml.title     product.to_s
        xml.pubDate   product.created_at.to_s(:rfc822)
        xml.link      product_url(product)
        xml.founder   profile_url(product.founder)
        xml.brand     product.brand.to_s
        xml.merchant  product.merchant.to_s
        xml.category  product.category.to_s
        xml.price     present(product).send(product.price.to_f > 0 ? :price : :marked_price)
        xml.available product.available?
        xml.priority_service product.prioritized?
        xml.images do
          product.images.each do |image|
            xml.image image_url(image)
          end
        end
      end
    end
  end
end
