class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.references :user, index: true, foreign_key: true
      t.string :provider
      t.string :uid
      t.string :name
      t.string :username
      t.string :email
      t.string :image
      t.string :gender
      t.integer :timezone_offset
      t.string :language
      t.string :url
      t.boolean :verified
      t.text :token
      t.string :secret
      t.string :refresh_token
      t.datetime :expires_at

      t.timestamps null: false
    end
  end
end
