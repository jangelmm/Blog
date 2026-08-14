class Project < ApplicationRecord
  include Sluggable
  has_one_attached :image

  validates :image, content_type: { in: %w[image/jpeg image/png image/webp image/gif] },
                    size: { less_than: 5.megabytes }

  validates :title, presence: true

  scope :ordered, -> { order(position: :asc, created_at: :desc) }

  def optimized_image
    image.variant(
      resize_to_limit: [800, 600], 
      format: :webp, 
      saver: { quality: 80 }
    ).processed
  end

  def tech_list
    (tech_stack || "").split(",").map(&:strip).reject(&:blank?)
  end
end