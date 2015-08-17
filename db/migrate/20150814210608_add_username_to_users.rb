class AddUsernameToUsers < ActiveRecord::Migration
  def up
    add_column :users, :username, :string, unique: true
    User.transaction { add_usernames }
    change_column :users, :username, :string, unique: true, index: true, null: false
  end

  def down
    remove_column :users, :username
  end

  def add_usernames
    User.find_each do |user|
      username = user.name.gsub(/[^a-z0-9]/i, '').downcase
      user.update_column :username, username
    end
  end
end
