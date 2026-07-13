class Post < ApplicationRecord
  include Sluggable

  has_one_attached :image

  validates :title, presence: true
  validates :body,  presence: true

  scope :published,  -> { where(published: true) }
  scope :recent,      -> { order(published_at: :desc, created_at: :desc) }

  before_validation :set_published_at

  private

  def set_published_at
    self.published_at ||= Time.current if published?
  end
end
