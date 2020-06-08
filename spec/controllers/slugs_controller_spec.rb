require 'rails_helper'

RSpec.describe Slugs::SlugsController do
  let(:params) {{}}
  
  shared_examples_for 'a successful request' do
    it { expect { subject }.not_to raise_error }
    it { expect(subject.response_code).to eq(200) }
  end

  shared_examples_for 'an unsuccessful request' do
    it { expect { subject }.not_to raise_error }
    it { expect(subject.response_code).to eq(400) }
  end

  describe '#origin_url' do
    before { Slug.create(origin_url: 'original_destination', slugified_slug: "abc") }
    subject { get :origin_url, params: params }
    let(:params) { {slug: {slugified_slug: 'abc' }} }

    it_behaves_like 'a successful request'

    it 'returns the corresponding origin_url in json' do
      expect(JSON.parse(subject.body)).to eq({"origin_url" => 'original_destination'})
    end

    context 'when slug is not found' do
      let(:params) {{ slug: { slugified_slug: '123456' } }}

      it_behaves_like 'an unsuccessful request'

      it 'returns a slug not found error in json' do
        expect(JSON.parse(subject.body)).to eq({"error" => 'Slug not found'})
      end
    end
  end

  describe '#slugify' do
    subject { get :slugify, params: params }
    let(:params) {{ url: 'this is one super long ass string that seems to go on for quite some time' }}

    it_behaves_like 'a successful request'

    it 'returns a slugified url' do
      expect(JSON.parse(subject.body)).to eq( { "slugified_slug" => "this-is-one-super-long-ass-str" })
    end
  end

  describe '#create' do
    subject { post :create, params: params }
    let(:params) {{ slug: { origin_url: origin_url, slugified_slug: slugified_slug } }}
    let(:origin_url) { 'flannery-beef/california-reserve-filet-mignon-steaks-gift-box' }
    let(:slugified_slug) { 'steak-promo' }

    it_behaves_like 'a successful request'

    it 'returns the instantiated slug' do
      expect(JSON.parse(subject.body)["slug"]["slugified_slug"]).to eq(Slug.last.slugified_slug)
    end

    context 'when missing origin_url' do
      let(:params) { nil }

      it_behaves_like 'an unsuccessful request'

      it 'returns an error stating missing param' do
        expect(JSON.parse(subject.body)["error"]).to eq("Missing origin_url")
      end
    end

    context 'when missing slugified_url' do
      let(:slugified_slug) { nil }

      it_behaves_like 'a successful request'

    it 'returns the instantiated slug' do
      expect(JSON.parse(subject.body)["slug"]["slugified_slug"]).to eq(Slug.last.slugify(origin_url))
    end
    end
  end

  describe '#update' do
    subject { post :update, params: params }
    before { Slug.create(origin_url: 'original_destination', slugified_slug: "abc", active: false) }
    let(:params) {{ slug: { origin_url: 'updated_origin_slug', slugified_slug: slugified_slug, active: true } }}

    context 'when existing slug found' do
      let(:slugified_slug) { 'abc' }

      it "should update the slug" do
        expect(JSON.parse(subject.body)["slug"]["active"]).to eq(true)
      end
    end

    context 'when slug not found' do
      let(:slugified_slug) { 'does-not-exist' }
      it_behaves_like 'an unsuccessful request'
    end

    context 'when missing params' do
      let(:params) { nil }
      it_behaves_like 'an unsuccessful request'
    end
  end

  describe '#api_status' do
    subject { get :api_status, params: params }
    
    it 'returns status 200' do
      expect(subject.response_code).to eq(200)
    end

    it 'returns a success json' do
      expect(JSON.parse(subject.body)).to eq({ "success" => true })
    end
  end
end