#encoding: UTF-8

xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0", 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.channel do
    xml.title "Recent products on Handlisted.in"
    xml.description "Shopping, Curated Shop"
    xml.link "http://handlisted.in"
    xml.language "en"
    xml.tag! 'atom:link', rel: 'self', type: 'application/rss+xml', href: recent_feed_url

    xml.image do
      xml.url "http://handlisted.in/images/handlisted-text-logo.png"
      xml.title "Recent products on Handlisted.in"
      xml.link "http://handlisted.in"
    end

    @products.each do |product|
      xml.item do
        xml.title     product.to_s
        xml.pubDate   product.created_at.to_s(:rfc822)
        xml.link      product_url(product)
        xml.author    "hello@handlisted.in (Handlisted.in)"
        xml.category  product.category.name
        xml.guid      product_short_url(product.id)
        xml.description present(product).rss_description
      end
    end
  end
end
