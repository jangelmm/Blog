class MediaAsset < ApplicationRecord
  has_one_attached :file

  validates :path, presence: true

  validates :file, size: { less_than: 50.megabytes, message: "El archivo no puede superar los 50 MB" }
end
