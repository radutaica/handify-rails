class Review < ApplicationRecord
  # Associations
  belongs_to :task
  belongs_to :reviewer, class_name: 'User'
  belongs_to :reviewee, class_name: 'User'

  # Enums
  enum :review_type, {
    customer_to_tasker: 'customer_to_tasker',
    tasker_to_customer: 'tasker_to_customer'
  }

  # Validations
  validates :task_id, :reviewer_id, :reviewee_id, presence: true
  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :review_type, presence: true
  validates :reviewer_id, uniqueness: { scope: :task_id, message: 'has already reviewed this task' }

  # Callbacks
  after_create :update_tasker_rating, if: :customer_to_tasker?

  # Scopes
  scope :public_reviews, -> { where(is_public: true) }
  scope :for_user, ->(user_id) { where(reviewee_id: user_id) }
  scope :by_user, ->(user_id) { where(reviewer_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :high_rated, -> { where('rating >= ?', 4) }

  # Methods
  def positive?
    rating >= 4
  end

  def negative?
    rating <= 2
  end

  private

  def update_tasker_rating
    return unless reviewee.tasker_profile

    reviewee.tasker_profile.update_rating(rating)
  end
end
