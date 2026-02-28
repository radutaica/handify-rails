# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist,
         :omniauthable, omniauth_providers: [:google_oauth2, :apple]

  # Enums
  enum :user_type, { customer: 'customer', tasker: 'tasker', both: 'both' }, prefix: true
  enum :status, { active: 'active', suspended: 'suspended', deleted: 'deleted', anonymized: 'anonymized' }, prefix: true

  # Associations
  has_one :tasker_profile, dependent: :destroy
  has_one :admin_user, dependent: :destroy
  has_many :addresses, dependent: :destroy

  # Tasks associations
  has_many :customer_tasks, class_name: 'Task', foreign_key: 'customer_id', dependent: :destroy
  has_many :assigned_tasks, class_name: 'Task', foreign_key: 'assigned_tasker_id', dependent: :nullify
  has_many :bids, foreign_key: 'tasker_id', dependent: :destroy

  # Direct requests
  has_many :sent_direct_requests, class_name: 'DirectRequest', foreign_key: 'customer_id', dependent: :destroy
  has_many :received_direct_requests, class_name: 'DirectRequest', foreign_key: 'tasker_id', dependent: :destroy

  # Tasker availability
  has_many :tasker_availabilities, foreign_key: 'tasker_id', dependent: :destroy

  # Transactions
  has_many :customer_transactions, class_name: 'Transaction', foreign_key: 'customer_id', dependent: :destroy
  has_many :tasker_transactions, class_name: 'Transaction', foreign_key: 'tasker_id', dependent: :destroy

  # Reviews
  has_many :given_reviews, class_name: 'Review', foreign_key: 'reviewer_id', dependent: :destroy
  has_many :received_reviews, class_name: 'Review', foreign_key: 'reviewee_id', dependent: :destroy

  # Messages
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy
  has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id', dependent: :destroy

  # Notifications
  has_many :notifications, dependent: :destroy

  # Favorites
  has_many :customer_favorites, class_name: 'Favorite', foreign_key: 'customer_id', dependent: :destroy
  has_many :tasker_favorites, class_name: 'Favorite', foreign_key: 'tasker_id', dependent: :destroy
  has_many :favorited_taskers, through: :customer_favorites, source: :tasker
  has_many :favorited_by_customers, through: :tasker_favorites, source: :customer

  # Portfolio
  has_many :portfolio_items, foreign_key: 'tasker_id', dependent: :destroy

  # Disputes
  has_many :raised_disputes, class_name: 'Dispute', foreign_key: 'raised_by', dependent: :destroy
  has_many :resolved_disputes, class_name: 'Dispute', foreign_key: 'resolved_by', dependent: :nullify

  # GDPR
  has_many :gdpr_consents, dependent: :destroy
  has_many :data_deletion_requests, dependent: :destroy
  has_many :audit_logs, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :phone, uniqueness: true, allow_nil: true
  validates :first_name, :last_name, presence: true
  validates :user_type, presence: true

  # Callbacks
  before_save :update_last_active_at, if: :will_save_change_to_updated_at?

  # Scopes
  scope :customers, -> { where(user_type: ['customer', 'both']) }
  scope :taskers, -> { where(user_type: ['tasker', 'both']) }
  scope :verified, -> { where(id_verified: true) }
  scope :active_users, -> { where(status: 'active') }

  def self.from_omniauth(provider:, uid:, email:, first_name:, last_name:, profile_image_url: nil)
    user = find_by(provider: provider, uid: uid) || find_by(email: email)

    if user
      user.update(provider: provider, uid: uid) if user.provider.blank?
      user
    else
      create!(
        provider: provider,
        uid: uid,
        email: email,
        first_name: first_name,
        last_name: last_name,
        profile_image_url: profile_image_url,
        password: Devise.friendly_token[0, 20],
        user_type: "customer"
      )
    end
  end

  private

  def update_last_active_at
    self.last_active_at = Time.current
  end
end

