class DataDeletionRequest < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :processed_by, class_name: 'User', optional: true

  # Enums
  enum :request_type, {
    data_export: 'data_export',
    data_deletion: 'data_deletion',
    data_rectification: 'data_rectification',
    data_portability: 'data_portability',
    processing_restriction: 'processing_restriction'
  }

  enum :status, {
    pending: 'pending',
    processing: 'processing',
    completed: 'completed',
    rejected: 'rejected'
  }

  # Validations
  validates :user_id, :request_type, :status, presence: true

  # Scopes
  scope :pending_requests, -> { where(status: 'pending') }
  scope :by_type, ->(type) { where(request_type: type) }
  scope :recent, -> { order(requested_at: :desc) }

  # Methods
  def process!(admin_user)
    update!(status: 'processing', processed_by: admin_user)
  end

  def complete!(export_url = nil)
    update!(
      status: 'completed',
      completed_at: Time.current,
      export_file_url: export_url
    )
  end

  def reject!(reason)
    update!(
      status: 'rejected',
      rejection_reason: reason,
      completed_at: Time.current
    )
  end

  def can_be_processed?
    pending? || processing?
  end
end
