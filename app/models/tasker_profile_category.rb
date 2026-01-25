class TaskerProfileCategory < ApplicationRecord
  # Associations
  belongs_to :tasker_profile
  belongs_to :category

  # Validations
  validates :tasker_profile_id, uniqueness: { scope: :category_id }
end
