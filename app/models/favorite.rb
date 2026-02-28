class Favorite < ApplicationRecord
  # Associations
  belongs_to :customer, class_name: 'User'
  belongs_to :tasker, class_name: 'User'

  # Validations
  validates :customer_id, :tasker_id, presence: true
  validates :customer_id, uniqueness: { scope: :tasker_id, message: 'has already favorited this tasker' }
  validate :cannot_favorite_self

  # Scopes
  scope :for_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :for_tasker, ->(tasker_id) { where(tasker_id: tasker_id) }
  scope :recent, -> { order(created_at: :desc) }

  private

  def cannot_favorite_self
    if customer_id == tasker_id
      errors.add(:base, 'Cannot favorite yourself')
    end
  end
end
