class AddUrlHashToProducts < ActiveRecord::Migration
  def up
    add_column :products, :url_hash, :string, limit: 32
    Product.transaction { add_url_hashes }
    change_column :products, :url_hash, :string, limit: 32, null: false
  end

  def down
    remove_column :products, :url_hash
  end

  def add_url_hashes
    Product.find_each do |product|
      hash = ProductScraper.url_hash_for(product.url)
      product.update_column :url_hash, hash
    end
  end
end
