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
    before { Slug.create(origin_url: 'http://original_destination', slugified_slug: "abc") }
    subject { get :origin_url, params: params }
    let(:params) { {slug: {slugified_slug: 'abc' }} }

    it_behaves_like 'a successful request'

    it 'returns the corresponding origin_url in json' do
      expect(JSON.parse(subject.body)).to eq({"origin_url" => 'http://original_destination'})
    end

    context 'when slug is not found' do
      let(:params) { {slug: {slugified_slug: '123456' }} }

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