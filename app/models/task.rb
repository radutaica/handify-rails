class Task < ApplicationRecord
  # Associations
  belongs_to :customer, class_name: 'User'
  belongs_to :category
  belongs_to :address
  belongs_to :assigned_tasker, class_name: 'User', optional: true

  has_many :bids, dependent: :destroy
  has_many :direct_requests, dependent: :nullify
  has_many :tasker_availabilities, dependent: :nullify
  has_many :transactions, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :disputes, dependent: :destroy
  has_many :portfolio_items, dependent: :nullify

  # Enums
  enum :pricing_type, {
    bidding: 'bidding',
    fixed_price: 'fixed_price',
    hourly_rate: 'hourly_rate'
  }

  enum :booking_type, {
    open_bidding: 'open_bidding',
    instant_book: 'instant_book',
    direct_request: 'direct_request'
  }

  enum :status, {
    draft: 'draft',
    open: 'open',
    assigned: 'assigned',
    in_progress: 'in_progress',
    completed: 'completed',
    cancelled: 'cancelled',
    disputed: 'disputed'
  }

  enum :urgency, {
    low: 'low',
    medium: 'medium',
    high: 'high'
  }

  # Validations
  validates :customer_id, :category_id, :address_id, presence: true
  validates :title, presence: true, length: { maximum: 200 }
  validates :description, presence: true
  validates :pricing_type, :booking_type, :status, :urgency, presence: true
  validates :estimated_hours, numericality: { greater_than: 0 }, allow_nil: true
  validates :budget_min, :budget_max, :fixed_price, :hourly_budget,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :open_tasks, -> { where(status: 'open') }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_urgency, ->(urgency) { where(urgency: urgency) }
  scope :recent, -> { order(created_at: :desc) }
  scope :instant_bookable, -> { where(booking_type: 'instant_book', status: 'open') }

  # Methods
  def assign_to(tasker)
    update(
      assigned_tasker: tasker,
      assigned_at: Time.current,
      status: 'assigned'
    )
  end

  def mark_completed
    update(
      completed_at: Time.current,
      status: 'completed'
    )
  end

  def cancel(reason)
    update(
      cancelled_at: Time.current,
      cancellation_reason: reason,
      status: 'cancelled'
    )
  end

  def can_be_bid_on?
    open? && booking_type == 'open_bidding'
  end
end
