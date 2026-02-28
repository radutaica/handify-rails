class AddImagesToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :images, :text, array: true, default: []
  end
end
