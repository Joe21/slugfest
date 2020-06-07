require 'rails_helper'

RSpec.describe Slug do
  subject { described_class.new(origin_url: origin_url, active: active) }
  let(:origin_url) { Faker::Internet.slug }
  let(:active) { true }

  it { is_expected.to validate_uniqueness_of(:slugified_slug) }

  describe '#slugify' do
    subject { super().slugify }

    context 'when nil' do
      let(:origin_url) { nil }
      
      it 'returns an empty string' do
        expect(subject).to eq('')
      end      
    end

    context 'when empty string' do
      let(:origin_url) { "   " }
      
      it 'returns an empty string' do
        expect(subject).to eq('')
      end
    end

    shared_examples_for 'a sanitized url encoded string' do
      it { expect{ subject }.not_to raise_error }

      it 'returns a string without the invalid character' do
        expect(subject).not_to include(violator)
      end
    end

    context 'when origin_url contains empty strings' do
      let(:origin_url) { "abc defg 123 " }
      let(:violator) { ' '}
      it_behaves_like 'a sanitized url encoded string'
    end

    context 'when origin_url contains &\'s' do
      let(:origin_url) { "a&w_rootbeer" }
      let(:violator) { '&\'' }
      it_behaves_like 'a sanitized url encoded string'
    end

    context 'when origin_url contains \'' do
      let(:origin_url) { "pros \ cons" }
      let(:violator) { '\'' }
      it_behaves_like 'a sanitized url encoded string'
    end

    context 'when origin_url contains `' do
      let(:origin_url) { "back`tick definitely breaks url" }
      let(:violator) { '`' }
      it_behaves_like 'a sanitized url encoded string'
    end

    context 'when origin_url contains unsanitized url encoded characters' do
      let(:origin_url) { "abc ¶™ efg" }
      let(:violator) { '¶' }
      it_behaves_like 'a sanitized url encoded string'
    end

    context 'when sanitized origin_url is over 30 character length' do
      let(:origin_url) { 'this string has forty characters12345678' }
      
      it 'returns a string with 30 characters' do
        expect(subject.length).to eq(30)
      end
    end
  end
end
