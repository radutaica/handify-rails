class PortfolioItem < ApplicationRecord
  # Associations
  belongs_to :tasker, class_name: 'User'
  belongs_to :category, optional: true
  belongs_to :task, optional: true

  # Validations
  validates :tasker_id, :title, :images, presence: true

  # Scopes
  scope :for_tasker, ->(tasker_id) { where(tasker_id: tasker_id) }
  scope :featured, -> { where(is_featured: true) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def toggle_featured!
    update!(is_featured: !is_featured)
  end
end
