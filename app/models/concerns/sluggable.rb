# Genera automáticamente un slug único a partir del título,
# para usarlo en URLs bonitas: /blog/mi-primer-post
module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, if: -> { slug.blank? && title.present? }
  end

  def to_param
    slug
  end

  private

  def generate_slug
    base = title.parameterize
    candidate = base
    n = 2
    while self.class.where(slug: candidate).where.not(id: id).exists?
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end
end
