class AdminUser < ApplicationRecord
  # Associations
  belongs_to :user

  # Enums
  enum :role, {
    super_admin: 'super_admin',
    admin: 'admin',
    moderator: 'moderator',
    support: 'support',
    dpo: 'dpo'
  }

  # Validations
  validates :user_id, presence: true, uniqueness: true
  validates :role, presence: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :by_role, ->(role) { where(role: role) }

  # Methods
  def has_permission?(permission_key)
    return true if super_admin?
    permissions&.dig(permission_key.to_s) == true
  end

  def grant_permission(permission_key)
    self.permissions ||= {}
    self.permissions[permission_key.to_s] = true
    save
  end

  def revoke_permission(permission_key)
    self.permissions ||= {}
    self.permissions[permission_key.to_s] = false
    save
  end
end
