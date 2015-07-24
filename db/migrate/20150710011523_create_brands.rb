class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.references :merchant, null: false, index: true, foreign_key: true
      t.string :name, null: false, index: true
      t.string :slug, null: false, index: true

      t.integer :average_rating, null: false, default: 0
      t.integer :ratings_count,  null: false, default: 0
      t.integer :products_count, null: false, default: 0

      t.timestamps null: false
    end
  end
end
