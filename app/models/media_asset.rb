class MediaAsset < ApplicationRecord
  has_one_attached :file

  validates :path, presence: true
end
