class Project < ApplicationRecord
  include Sluggable

  has_one_attached :image

  validates :title, presence: true

  scope :ordered, -> { order(position: :asc, created_at: :desc) }

  # Devuelve el tech_stack como array de strings limpio
  def tech_list
    (tech_stack || "").split(",").map(&:strip).reject(&:blank?)
  end
end
