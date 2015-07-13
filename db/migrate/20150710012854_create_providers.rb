class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name  # STI column
      t.string :slug, unique: true
      t.string :priority_service_name

      t.timestamps null: false
    end
  end
end
