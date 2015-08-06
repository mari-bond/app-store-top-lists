require "spec_helper"
require "./app/appstore_client"

RSpec.describe AppstoreClient do
  def stub_request(request, status, response)
    faraday = Faraday.new do |builder|
      builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get(request) { |env| [status, {}, response.to_json] }
      end
    end
    allow_any_instance_of(AppstoreClient).to receive(:connection).and_return(faraday)
  end

  describe 'should fetch top apps for specific category' do
    let(:request) { 'https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewTop?' +
      'dataOnly=true&genreId=6001&l=en&popId=30'
    }

    it 'success' do
      response = {"adamIds" => ["749133301","517329357"]}
      stub_request(request, 200, response)
      expect(AppstoreClient.new.top(6001)).to eq response
    end

    it 'fail' do
      stub_request(request, 400, 'Some errors')
      expect(AppstoreClient.new.top(6001)).to eq nil
    end
  end

  describe 'should find app by id' do
    let(:request) {'https://itunes.apple.com/lookup?id=6723'}

    it 'success' do
      response = {"description" => "Top-ranked Yelp"}
      stub_request(request, 200, response)
      expect(AppstoreClient.new.lookup(6723)).to eq response
    end

    it 'fail' do
      stub_request(request, 400, 'Some errors')
      expect(AppstoreClient.new.lookup(6723)).to eq nil
    end
  end
end
