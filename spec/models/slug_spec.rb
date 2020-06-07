require 'rails_helper'

RSpec.describe Slug do
  subject { described_class.new(origin_url: origin_url, slugified_slug: slugified_slug, active: active) }
  let(:origin_url) { Faker::Internet.slug + " #{Time.now.to_i}" }
  let(:slugified_slug) { nil }
  let(:active) { true }

  describe '#slugify' do
    subject { super().slugify(origin_url) }

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
        expect(subject.length).to eq(Slug::MAX_LENGTH)
      end
    end
  end

  describe 'validations' do
    context 'without a slugified_slug' do
      it "persists a new slug" do
        expect { subject.save }.to change{ Slug.count }.by(1)
      end

      it 'slugifies off the origin_url' do
        subject.save
        expect(subject.slugified_slug).to eq(subject.slugify(origin_url))
      end
    end

    context 'with a provided slugified_slug' do
      let(:slugified_slug) { "I want to manually override this slug" }

      it "persists a new slug" do
        expect { subject.save }.to change{ Slug.count }.by(1)
      end
      
      it 'persists a slugified/sanitized slug' do
        subject.save
        expect(subject.slugified_slug).to eq(subject.slugify(slugified_slug))
      end
    end

    context 'when slug collision occurs' do
      context 'without a prior collision' do
        before { Slug.create(origin_url: "goldbelly.com/unique_treat", slugified_slug: "goldbelly.com/unique_treat") }
        let(:slugified_slug) { "goldbelly.com/unique_treat" }

        it 'persists a new slug' do
          expect { subject.save }.to change{ Slug.count }.by(1)
        end

        it 'appends a version number onto the sanitized slugified_slug' do
          subject.save
          expect(subject.slugified_slug).to eq('goldbelly-com-unique-treat-1')
        end
      end

      context 'with prior collisions' do
        before { Slug.create(origin_url: "goldbelly.com/unique_treat", slugified_slug: "goldbelly-com-unique-treat-5") }
        let(:slugified_slug) { "goldbelly-com-unique-treat-5" }

        it 'persists a new slug' do
          expect { subject.save }.to change{ Slug.count }.by(1)
        end

        it 'increments the version onto the sanitized slugified_slug' do
          subject.save
          expect(subject.slugified_slug).to eq('goldbelly-com-unique-treat-6')
        end        
      end
    end
  end
end
