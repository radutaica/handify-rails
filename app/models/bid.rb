class Bid < ApplicationRecord
  # Associations
  belongs_to :task
  belongs_to :tasker, class_name: 'User'

  # Enums
  enum :status, {
    pending: 'pending',
    accepted: 'accepted',
    rejected: 'rejected',
    withdrawn: 'withdrawn'
  }

  # Validations
  validates :task_id, :tasker_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :estimated_hours, numericality: { greater_than: 0 }, allow_nil: true
  validates :tasker_id, uniqueness: { scope: :task_id, message: 'has already bid on this task' }

  # Callbacks
  validate :task_can_receive_bids, on: :create

  # Scopes
  scope :for_task, ->(task_id) { where(task_id: task_id) }
  scope :by_tasker, ->(tasker_id) { where(tasker_id: tasker_id) }
  scope :pending_bids, -> { where(status: 'pending') }
  scope :lowest_first, -> { order(amount: :asc) }
  scope :recent_first, -> { order(created_at: :desc) }

  # Methods
  def accept!
    transaction do
      update!(status: 'accepted')
      task.assign_to(tasker)
      reject_other_bids
    end
  end

  def reject!
    update!(status: 'rejected')
  end

  def withdraw!
    update!(status: 'withdrawn')
  end

  private

  def task_can_receive_bids
    unless task&.can_be_bid_on?
      errors.add(:task, 'is not accepting bids')
    end
  end

  def reject_other_bids
    task.bids.where.not(id: id).pending.update_all(status: 'rejected')
  end
end
