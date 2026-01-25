# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'csv'

# ===========================================
# CATEGORIES SEED
# ===========================================
puts "Loading categories..."

csv_file = Rails.root.join('db', 'seeds', 'categories.csv')

if File.exist?(csv_file)
  # First pass: Create all root categories (no parent)
  CSV.foreach(csv_file, headers: true) do |row|
    next if row['parent_slug'].present?

    Category.find_or_create_by!(slug: row['name'].parameterize) do |category|
      category.name = row['name']
      category.description = row['description']
      category.icon_url = row['icon_name'] # Store icon name, frontend will handle the actual icon
      category.suggested_hourly_rate = row['suggested_hourly_rate'].to_d if row['suggested_hourly_rate'].present?
      category.sort_order = row['sort_order'].to_i
      category.is_active = true
    end
  end

  puts "  -> Created #{Category.root_categories.count} root categories"

  # Second pass: Create all subcategories (with parent)
  CSV.foreach(csv_file, headers: true) do |row|
    next unless row['parent_slug'].present?

    parent = Category.find_by(slug: row['parent_slug'])

    if parent
      Category.find_or_create_by!(slug: row['name'].parameterize) do |category|
        category.name = row['name']
        category.description = row['description']
        category.icon_url = row['icon_name']
        category.parent = parent
        category.suggested_hourly_rate = row['suggested_hourly_rate'].to_d if row['suggested_hourly_rate'].present?
        category.sort_order = row['sort_order'].to_i
        category.is_active = true
      end
    else
      puts "  -> WARNING: Parent category '#{row['parent_slug']}' not found for '#{row['name']}'"
    end
  end

  puts "  -> Created #{Category.where.not(parent_id: nil).count} subcategories"
  puts "  -> Total categories: #{Category.count}"
else
  puts "  -> WARNING: categories.csv not found at #{csv_file}"
end

puts "Seeding completed!"
