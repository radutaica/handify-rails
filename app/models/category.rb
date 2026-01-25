class Category < ApplicationRecord
  # Associations
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :subcategories, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  has_many :tasks, dependent: :restrict_with_error
  has_many :direct_requests, dependent: :restrict_with_error
  has_many :portfolio_items, dependent: :nullify

  # Validations
  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
  validates :suggested_hourly_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Callbacks
  before_validation :generate_slug, if: :name_changed?

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :root_categories, -> { where(parent_id: nil) }
  scope :ordered, -> { order(sort_order: :asc, name: :asc) }

  # Methods
  def root?
    parent_id.nil?
  end

  def has_subcategories?
    subcategories.any?
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
