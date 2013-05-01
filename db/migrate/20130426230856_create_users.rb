class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:users, :id => false, :primary_key => :uid) do |t|
      t.integer :uid,  :null => false
      t.text :ssh_key, :null => false
      t.timestamps
    end

    add_index :users, :uid, :unique => true
  end
end
