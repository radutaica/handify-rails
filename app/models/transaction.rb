class Transaction < ApplicationRecord
  # Associations
  belongs_to :task
  belongs_to :customer, class_name: 'User'
  belongs_to :tasker, class_name: 'User'

  # Enums
  enum :status, {
    pending: 'pending',
    held: 'held',
    completed: 'completed',
    refunded: 'refunded',
    failed: 'failed'
  }

  enum :payment_method, {
    card: 'card',
    bank_transfer: 'bank_transfer',
    cash: 'cash'
  }

  # Validations
  validates :task_id, :customer_id, :tasker_id, presence: true
  validates :amount, :platform_fee, :platform_fee_percentage, :tasker_amount,
            presence: true, numericality: { greater_than: 0 }

  # Callbacks
  before_validation :calculate_amounts, if: -> { amount_changed? || platform_fee_percentage_changed? }

  # Scopes
  scope :for_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :for_tasker, ->(tasker_id) { where(tasker_id: tasker_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def hold_payment!
    update!(status: 'held', paid_at: Time.current)
  end

  def release_payment!
    return false unless held?

    transaction do
      update!(status: 'completed', released_at: Time.current)
      tasker.tasker_profile&.update_stats(tasker_amount)
    end
  end

  def refund!
    return false unless %w[held completed].include?(status)

    update!(status: 'refunded', refunded_at: Time.current)
  end

  def mark_failed!
    update!(status: 'failed')
  end

  private

  def calculate_amounts
    return unless amount && platform_fee_percentage

    self.platform_fee = (amount * platform_fee_percentage / 100).round(2)
    self.tasker_amount = (amount - platform_fee).round(2)
  end
end
