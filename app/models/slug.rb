class Slug < ApplicationRecord
  before_validation :generate_slug, if: :should_generate_slug?
  before_validation :resolve_slug_conflicts, if: :has_dirty_slug?
  validates :slugified_slug, uniqueness: true


  def slugify(str)
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