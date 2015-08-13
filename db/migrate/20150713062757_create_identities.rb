class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.references :user,              index: true, foreign_key: true
      t.string   :provider,            null: false, limit: 16
      t.string   :uid,                 null: false, limit: 55
      t.string   :name
      t.string   :username
      t.string   :email
      t.string   :image
      t.string   :gender,              limit: 8
      t.integer  :timezone_offset
      t.string   :language,            default: "en", limit: 4
      t.string   :url
      t.boolean  :verified,            default: false
      t.text     :token,               index: true, null: false
      t.string   :secret
      t.string   :refresh_token
      t.datetime :expires_at

      t.timestamps null: false
    end

    add_index :identities, [:provider, :uid]
  end
end
