class Slug < ApplicationRecord
  # before_validation :generate_slug, if: :should_generate_slug?
  # before_validation :resolve_slug_conflicts, if: :has_dirty_slug?
  validates :slugified_slug, uniqueness: true

  MAX_LENGTH = 30

  def slugify
    return '' if origin_url.blank?
    origin_url.downcase.gsub(/[`']/, '').tr('_', ' ').gsub('&', ' and ').strip.parameterize[0...MAX_LENGTH]
  end

  def generate_slug
  end

  def should_generate_slug?
  end

  def resolve_slug_conflicts
  end

  def has_dirty_slug?
  end

end