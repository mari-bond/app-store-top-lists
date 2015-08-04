require "spec_helper"
require "./app/appstore_client"

RSpec.describe AppstoreClient do
  describe 'should fetch top apps for specific category' do
    it 'success' do
      response = {"adamIds":["749133301","517329357"]}
      expect(AppstoreClient.new.top(6001)).to eq response
    end

    it 'fail' do
      expect(AppstoreClient.new.top(6001)).to eq nil
    end
  end

  describe 'should find app by id' do
    it 'success' do
      response = {"description":"Top-ranked Yelp"}
      expect(AppstoreClient.new.lookup(6723)).to eq response
    end

    it 'fail' do
      expect(AppstoreClient.new.lookup(6723)).to eq nil
    end
  end
end
