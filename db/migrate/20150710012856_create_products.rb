class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      # associations
      t.references :user, index: true, foreign_key: true
      t.text :images, array: true
      t.text :categories, array: true

      # private
      t.string :pid
      t.string :slug, uniq: true
      t.string :original_name

      # user facing
      t.string :url
      t.string :name
      t.string :brand_name
      t.text   :note
      t.string :product_type # STI

      # text fields
      t.text :features, array: true
      t.text :description

      # pricing
      t.monetize :price
      t.monetize :marked_price

      # booleans
      t.boolean :available, default: false
      t.boolean :priority_service, default: false

      # ratings/statistics
      t.integer :average_rating
      t.integer :ratings_count

      t.timestamps null: false
    end
  end
end
