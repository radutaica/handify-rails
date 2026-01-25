class Notification < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :user_id, :type, :title, :message, presence: true

  # Scopes
  scope :unread, -> { where(is_read: false) }
  scope :read_notifications, -> { where(is_read: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(type: type) }

  # Methods
  def mark_as_read!
    update!(is_read: true, read_at: Time.current)
  end

  def self.mark_all_as_read_for_user(user_id)
    where(user_id: user_id, is_read: false).update_all(is_read: true, read_at: Time.current)
  end

  # Class methods for creating specific notification types
  def self.create_bid_received(task, bid)
    create!(
      user: task.customer,
      type: 'bid_received',
      title: 'New bid received',
      message: "#{bid.tasker.first_name} placed a bid of #{bid.amount} on your task",
      related_id: bid.id
    )
  end

  def self.create_task_assigned(task)
    create!(
      user: task.assigned_tasker,
      type: 'task_assigned',
      title: 'Task assigned to you',
      message: "You've been assigned to: #{task.title}",
      related_id: task.id
    )
  end

  def self.create_payment_received(transaction)
    create!(
      user: transaction.tasker,
      type: 'payment_received',
      title: 'Payment received',
      message: "You received #{transaction.tasker_amount} for completing a task",
      related_id: transaction.id
    )
  end
end
