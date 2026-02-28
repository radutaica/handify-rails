# frozen_string_literal: true

class AddColorToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :color, :string, limit: 20
  end
end
