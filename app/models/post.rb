class Post < ApplicationRecord
  include Sluggable
  has_one_attached :image

  # Validaciones de imagen
  validates :image, content_type: { in: %w[image/jpeg image/png image/webp image/gif] },
                    size: { less_than: 5.megabytes }

  validates :path, presence: true
  validate :path_format_valido

  before_validation :normalizar_path

  scope :published, -> { where(published: true) }
  scope :recent, -> { order(published_at: :desc, created_at: :desc) }

  # Variante para la portada del post y las tarjetas
  def optimized_image
    image.variant(
      resize_to_limit: [1200, 800], 
      format: :webp, 
      saver: { quality: 80 }
    ).processed
  end

  def path_segments
    path.to_s.split("/").reject(&:blank?)
  end

  private

  # ... (resto de tus métodos privados intactos)
end