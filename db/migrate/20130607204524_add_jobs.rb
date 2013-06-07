class AddJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :repo
      t.string :user
      t.string :branch
      t.text :config
      t.text :output
      t.integer :exit_status

      t.timestamps
    end
  end
end
