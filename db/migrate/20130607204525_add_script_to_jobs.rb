class AddScriptToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :script, :text
  end
end
