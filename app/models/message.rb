class Message < ApplicationRecord
  # Associations
  belongs_to :task, optional: true
  belongs_to :direct_request, optional: true
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  # Validations
  validates :sender_id, :receiver_id, :message, presence: true
  validate :must_have_task_or_direct_request

  # Callbacks
  after_create :create_notification

  # Scopes
  scope :for_task, ->(task_id) { where(task_id: task_id) }
  scope :for_direct_request, ->(request_id) { where(direct_request_id: request_id) }
  scope :between_users, ->(user1_id, user2_id) {
    where('(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)',
          user1_id, user2_id, user2_id, user1_id)
  }
  scope :unread, -> { where(is_read: false) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def mark_as_read!
    update!(is_read: true, read_at: Time.current)
  end

  private

  def must_have_task_or_direct_request
    if task_id.blank? && direct_request_id.blank?
      errors.add(:base, 'Message must be associated with either a task or a direct request')
    end
  end

  def create_notification
    Notification.create!(
      user: receiver,
      type: 'message_received',
      title: "New message from #{sender.first_name}",
      message: message.truncate(100),
      related_id: id
    )
  end
end
