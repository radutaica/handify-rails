class DirectRequest < ApplicationRecord
  # Associations
  belongs_to :customer, class_name: 'User'
  belongs_to :tasker, class_name: 'User'
  belongs_to :category
  belongs_to :address
  belongs_to :task, optional: true

  has_many :messages, dependent: :destroy

  # Enums
  enum :status, {
    pending: 'pending',
    accepted: 'accepted',
    rejected: 'rejected',
    countered: 'countered',
    expired: 'expired'
  }

  # Validations
  validates :customer_id, :tasker_id, :category_id, :address_id, presence: true
  validates :title, presence: true, length: { maximum: 200 }
  validates :description, presence: true
  validates :proposed_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :tasker_counter_amount, numericality: { greater_than: 0 }, allow_nil: true
  validates :estimated_hours, numericality: { greater_than: 0 }, allow_nil: true

  # Callbacks
  before_create :set_expiration_date

  # Scopes
  scope :pending_requests, -> { where(status: 'pending') }
  scope :for_tasker, ->(tasker_id) { where(tasker_id: tasker_id) }
  scope :from_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :not_expired, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  # Methods
  def accept!
    return false if expired?

    transaction do
      task = create_task_from_request
      update!(status: 'accepted', task: task)
      task.assign_to(tasker)
    end
  end

  def reject!
    update!(status: 'rejected')
  end

  def counter_offer!(amount, message = nil)
    update!(
      status: 'countered',
      tasker_counter_amount: amount,
      tasker_message: message
    )
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  private

  def set_expiration_date
    self.expires_at ||= 7.days.from_now
  end

  def create_task_from_request
    Task.create!(
      customer: customer,
      category: category,
      address: address,
      title: title,
      description: description,
      task_date: preferred_date,
      task_time: preferred_time,
      estimated_hours: estimated_hours,
      pricing_type: 'fixed_price',
      fixed_price: tasker_counter_amount || proposed_amount,
      booking_type: 'direct_request',
      status: 'assigned',
      assigned_tasker: tasker,
      assigned_at: Time.current
    )
  end
end
