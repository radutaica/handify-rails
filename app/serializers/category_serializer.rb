# frozen_string_literal: true

class CategorySerializer
  def initialize(category)
    @category = category
  end

  def serializable_hash
    {
      id: @category.id,
      name: @category.name,
      iconName: @category.icon_url, # icon_url stores the icon name
      color: @category.color,
      description: @category.description,
      parent_id: @category.parent_id
    }
  end

  def self.serialize_collection(categories)
    categories.map { |c| new(c).serializable_hash }
  end
end
