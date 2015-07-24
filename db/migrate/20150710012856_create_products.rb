class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      # associations
      t.references :founder,  null: false, index: true
      t.references :merchant, null: false, index: true, foreign_key: true
      t.references :brand,    index: true, foreign_key: true
      t.references :category, index: true, foreign_key: true
      t.text :images, array: true

      # private
      t.string :pid, null: false, index: true
      t.string :slug, null: false, uniq: true
      t.string :original_name, null: false

      # user facing
      t.string :url, null: false
      t.string :name
      t.text   :note

      # text fields
      t.text :features, array: true
      t.text :description

      # pricing
      t.monetize :price
      t.monetize :marked_price

      # booleans
      t.boolean :available,   null: false, default: false
      t.boolean :prioritized, null: false, default: false

      # ratings/statistics
      t.integer :average_rating, null: false, default: 0
      t.integer :ratings_count,  null: false, default: 0

      # Optimistic locking..
      t.string :lock_version, default: 0, null: false
      t.timestamps null: false
    end

    add_index :products, [:merchant_id, :pid]
    add_foreign_key :products, :users, column: :founder_id
  end
end
