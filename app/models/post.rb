# app/models/post.rb
class Post < ApplicationRecord
  include Sluggable
  has_one_attached :image

  validates :path, presence: true
  validate :path_format_valido

  before_validation :normalizar_path

  scope :published, -> { where(published: true) }
  scope :recent, -> { order(published_at: :desc, created_at: :desc) }

  def path_segments
    path.to_s.split("/").reject(&:blank?)
  end

  private

  def normalizar_path
    return if path.blank?
    self.path = path.strip.split("/").reject(&:blank?).join("/")
  end

  def path_format_valido
    return if path.blank?
    unless path.match?(%r{\A[\w\sÁÉÍÓÚÑáéíóúñ\-]+(/[\w\sÁÉÍÓÚÑáéíóúñ\-]+)*\z})
      errors.add(:path, "solo puede contener letras, números, espacios, guiones y '/'")
    end
  end
end
