class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      t.string :name, null: false, index: true, unique: true, limit: 20
      t.string :service
      t.string :slug, unique: true, null: false

      t.integer :brands_count, null: false, default: 0

      t.timestamps null: false
    end
  end
end
