class CreateTaskerProfileCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :tasker_profile_categories, id: :uuid do |t|
      t.uuid :tasker_profile_id, null: false
      t.uuid :category_id, null: false

      t.timestamps
    end

    add_foreign_key :tasker_profile_categories, :tasker_profiles
    add_foreign_key :tasker_profile_categories, :categories
    add_index :tasker_profile_categories, [:tasker_profile_id, :category_id], unique: true, name: 'index_tasker_profile_categories_unique'
  end
end
