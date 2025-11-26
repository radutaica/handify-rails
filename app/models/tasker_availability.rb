class TaskerAvailability < ApplicationRecord
  # Associations
  belongs_to :tasker, class_name: 'User'
  belongs_to :task, optional: true

  # Validations
  validates :tasker_id, :date, :start_time, :end_time, presence: true
  validates :tasker_id, uniqueness: { scope: [:date, :start_time] }
  validate :end_time_after_start_time

  # Scopes
  scope :for_tasker, ->(tasker_id) { where(tasker_id: tasker_id) }
  scope :available, -> { where(is_available: true, is_booked: false) }
  scope :booked, -> { where(is_booked: true) }
  scope :for_date, ->(date) { where(date: date) }
  scope :upcoming, -> { where('date >= ?', Date.current) }

  # Methods
  def book_for_task!(task)
    update!(is_booked: true, task: task)
  end

  def release_booking!
    update!(is_booked: false, task: nil)
  end

  def duration_in_hours
    return 0 unless start_time && end_time

    (end_time - start_time) / 1.hour
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time

    if end_time <= start_time
      errors.add(:end_time, 'must be after start time')
    end
  end
end
