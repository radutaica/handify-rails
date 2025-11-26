class Dispute < ApplicationRecord
  # Associations
  belongs_to :task
  belongs_to :raised_by, class_name: 'User'
  belongs_to :resolved_by, class_name: 'User', optional: true

  # Enums
  enum :status, {
    open: 'open',
    investigating: 'investigating',
    resolved: 'resolved',
    closed: 'closed'
  }

  # Validations
  validates :task_id, :raised_by, :reason, presence: true

  # Scopes
  scope :open_disputes, -> { where(status: 'open') }
  scope :by_task, ->(task_id) { where(task_id: task_id) }
  scope :raised_by_user, ->(user_id) { where(raised_by: user_id) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def resolve!(admin_user, resolution_text)
    transaction do
      update!(
        status: 'resolved',
        resolution: resolution_text,
        resolved_by: admin_user,
        resolved_at: Time.current
      )
      task.update!(status: 'disputed')
    end
  end

  def close!
    update!(status: 'closed')
  end

  def investigate!
    update!(status: 'investigating')
  end
end
