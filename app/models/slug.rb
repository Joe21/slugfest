class Slug < ApplicationRecord
  before_validation :generate_default_slug, if: :should_generate_slug?
  before_validation :resolve_slug_collision, if: :has_slug_collision?
  validates :origin_url, presence: true
  validates :slugified_slug, presence: true, uniqueness: true

  MAX_LENGTH = 30

  def slugify(str)
    return '' if str.blank?
    str.downcase.gsub(/[`']/, '').tr('_', ' ').gsub('&', ' and ').parameterize[0...MAX_LENGTH]
  end

  # Ensure all writes sanitizes the slug
  def slugified_slug=(str)
    write_attribute(:slugified_slug, slugify(str))
  end

  private

  def should_generate_slug?
    slugified_slug.blank?
  end

  # if no slugified slug is presented, it will slugify the origin_url
  def generate_default_slug
    self.slugified_slug = slugify(origin_url)
  end

  def has_slug_collision?
    # More broader search via ILIKE not usable in SQLite3
    # - SLUG.where('slugified_slug ILIKE', slugified_slug) 
    Slug.find_by(slugified_slug: slugified_slug).present?
  end

  def resolve_slug_collision
    conflicts = Slug.where('slugified_slug LIKE ?', "#{slugified_slug}")
    resolve_conflicts(determine_conflicts(conflicts))
  end

  def determine_conflicts(conflicts)
    conflicts.pluck(:slugified_slug).reduce(0) do |memo, s|
      version = s.split('-').last
      version = 1 if version.to_i.zero? && s == slugified_slug
      [memo, version.to_i].max
    end
  end

  def resolve_conflicts(conflict_count)
    ends_in_int? ? increment_conflict : append_conflict(conflict_count)
  end

  def ends_in_int?
    slugified_slug.split('-').last.to_i.to_s == slugified_slug.split('-').last
  end

  def increment_conflict
    incremented_val = (self.slugified_slug.split('-').last.to_i + 1).to_s
    self.slugified_slug = self.slugified_slug.split('-').tap { |a| a.pop }.push(incremented_val).join('-')
  end
  
  def append_conflict(conflict_count)
    counter = conflict_count == 1 ? 1 : conflict_count + 1
    self.slugified_slug +=  "-#{counter}" 
  end
end