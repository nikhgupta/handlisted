class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.integer :user_id, null: false, index: true
      t.integer :target_product_id, null: false, index: true

      t.timestamps null: false
    end
  end
end
