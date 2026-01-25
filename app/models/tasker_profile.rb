class TaskerProfile < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :tasker_profile_categories, dependent: :destroy
  has_many :categories, through: :tasker_profile_categories

  # Enums
  enum :background_check_status, {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected'
  }

  # Validations
  validates :user_id, presence: true, uniqueness: true
  validates :hourly_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :instant_booking_buffer_hours, numericality: { greater_than_or_equal_to: 0 }
  validates :avg_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :total_tasks_completed, numericality: { greater_than_or_equal_to: 0 }
  validates :response_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :verified, -> { where(background_check_status: 'approved') }
  scope :instant_booking_available, -> { where(allows_instant_booking: true) }
  scope :with_high_rating, -> { where('avg_rating >= ?', 4.0) }

  # Methods
  def update_rating(new_rating)
    total_reviews = user.received_reviews.count
    return if total_reviews.zero?

    self.avg_rating = user.received_reviews.average(:rating).to_f.round(2)
    save
  end

  def update_stats(task_amount)
    increment!(:total_tasks_completed)
    increment!(:total_earnings, task_amount)
  end
end
