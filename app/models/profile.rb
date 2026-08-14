class Profile < ApplicationRecord
  has_one_attached :photo

  # Validación de seguridad y peso
  validates :photo, content_type: { in: %w[image/jpeg image/png image/webp image/gif] },
                    size: { less_than: 5.megabytes, message: "no puede superar los 5 MB" }

  validates :name, presence: true

  # Variante optimizada para la biografía
  def optimized_photo
    photo.variant(
      resize_to_fill: [400, 400], 
      format: :webp, 
      saver: { quality: 80 }
    ).processed
  end
end