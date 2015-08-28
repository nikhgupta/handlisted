class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :commentable, polymorphic: true
      t.references :user, null: false
      t.text :comment, null: false
      t.string :role, default: 'comments'
      t.timestamps null: false
    end

    add_index :comments, :commentable_type
    add_index :comments, :commentable_id
    add_index :comments, :user_id
  end

  def self.down
    drop_table :comments
  end
end
