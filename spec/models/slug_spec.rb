require 'rails_helper'

RSpec.describe Slug do
  subject { described_class.new(origin_url: origin_url, active: active) }
  let(:origin_url) { Faker::Internet.slug }
  let(:active) { true }

  it { is_expected.to validate_uniqueness_of(:slugified_slug) }

  describe '#slugify' do
    it 'bla ' do
      binding.pry
    end
  end
end