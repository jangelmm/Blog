class Project < ApplicationRecord
  include Sluggable

  has_one_attached :image

  validates :title, presence: true

  scope :ordered, -> { order(position: :asc, created_at: :desc) }

  def tech_list
    (tech_stack || "").split(",").map(&:strip).reject(&:blank?)
  end
end
