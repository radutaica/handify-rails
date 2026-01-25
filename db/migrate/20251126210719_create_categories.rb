class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :name, limit: 100, null: false
      t.string :slug, limit: 100, null: false
      t.text :description
      t.string :icon_url, limit: 500
      t.references :parent, type: :uuid, foreign_key: { to_table: :categories }
      t.decimal :suggested_hourly_rate, precision: 10, scale: 2
      t.boolean :is_active, default: true
      t.integer :sort_order, default: 0

      t.timestamps
    end

    add_index :categories, :slug, unique: true
  end
end
