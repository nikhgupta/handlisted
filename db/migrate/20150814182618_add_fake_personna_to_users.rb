class AddFakePersonnaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fake_personna, :boolean, default: false
  end
end
