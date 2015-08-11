require "spec_helper"
require "./app/api"

RSpec.describe Api do
  let(:app1) {App.new id: '1', name: 'App1', description: 'App1 desc', icon_url: 'ur1',
    publisher_id: '2434', publisher_name: 'Yelp', price: '1.99', version: '3.4.5', rating: '3' }

  let(:app2) {App.new id: '2', name: 'App2', description: 'App2 desc', icon_url: 'url2',
    publisher_id: '5678', publisher_name: 'Fizz', price: '3', version: '1.1', rating: '4.5' }
  let(:app3) {App.new id: '3', name: 'App3', description: 'App3 desc', icon_url: 'url3',
    publisher_id: '9123', publisher_name: 'GoingApps', price: '2.99', version: '2.0', rating: '6.0' }

  let(:app4) {App.new id: '4', name: 'App4', description: 'App4 desc', icon_url: 'url4',
    publisher_id: '2434', publisher_name: 'Yelp', price: '0.00', version: '3.2', rating: '2.5' }
  let(:app5) {App.new id: '5', name: 'App5', description: 'App5 desc', icon_url: 'url5',
    publisher_id: '9123', publisher_name: 'GoingApps', price: '0.00', version: '6.0', rating: '11.0' }
  let(:app6) {App.new id: '6', name: 'App6', description: 'App6 desc', icon_url: 'url6',
    publisher_id: '5678', publisher_name: 'Fizz', price: '0.00', version: '8.0', rating: '7.2' }
  let(:app7) {App.new id: '7', name: 'App7', description: 'App7 desc', icon_url: 'url7',
    publisher_id: '5678', publisher_name: 'Fizz', price: '0.00', version: '1.0', rating: '8.4' }
  let(:app8) {App.new id: '8', name: 'App8', description: 'App8 desc', icon_url: 'url8',
    publisher_id: '5678', publisher_name: 'Fizz', price: '0.00', version: '9.2', rating: '9.7' }
  let(:app9) {App.new id: '9', name: 'App9', description: 'App9 desc', icon_url: 'url9',
    publisher_id: '9123', publisher_name: 'GoingApps', price: '0.00', version: '1.3', rating: '2.7' }

  def app
    Api # this defines the active application for this test
  end

  def stub_appstore_requests
    grouped_apps = { paid: [app1], grossing: [app2, app3], free: [app4, app5, app6, app7, app8, app9] }
    grouped_app_ids = grouped_apps.inject({}){ |h, (group, apps)| h[group] = apps.map{|app| app.id}; h }
    faraday = Faraday.new do |builder|
      builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub_top_requests(stub, grouped_app_ids)
        stub_lookup_requests(stub, grouped_apps)
      end
    end
    allow_any_instance_of(AppstoreClient).to receive(:connection).and_return(faraday)
  end

  before do
    stub_appstore_requests
  end

  describe 'list of apps by category and monetization' do
    it "should return error if monetization is invalid" do
      get "/categories/6001/apps/fjg"

      expect(last_response.status).to eq 404
    end

    it "should return error if category id is invalid" do
      get "/categories/uiuy/apps/free"

      expect(last_response.status).to eq 404
    end

    it "should return blank array" do
      get "/categories/90/apps/paid"

      expect(last_response.body).to eq('[]')
      expect(last_response.status).to eq 200
    end

    it "should return array of paid apps in weather category (6001)" do
      apps = [app1]
      get "/categories/6001/apps/paid"

      expect(last_response.body).to eq(apps.to_json)
      expect(last_response.status).to eq 200
    end

    it "should return array of free apps in weather category (6001)" do
      apps = [app4, app5, app6, app7, app8, app9]
      get "/categories/6001/apps/free"

      expect(last_response.body).to eq(apps.to_json)
      expect(last_response.status).to eq 200
    end

    it "should return array of grossing apps in weather category (6001)" do
      apps = [app2, app3]
      get "/categories/6001/apps/grossing"

      expect(last_response.body).to eq(apps.to_json)
      expect(last_response.status).to eq 200
    end
  end

  describe 'app by category, monetization and rank' do
    it "should return error if monetization is invalid" do
      get "/categories/6001/apps/fjg"

      expect(last_response.status).to eq 404
    end

    it "should return error if category id is invalid" do
      get "/categories/uiuy/apps/free"

      expect(last_response.status).to eq 404
    end

    it "should return error if rank is invalid" do
      get "/categories/6001/apps/paid/fg"

      expect(last_response.status).to eq 404
    end

    it "should return bad request error" do
      data = { errors: 'App store error' }
      get "/categories/90/apps/paid/1"

      expect(last_response.body).to eq(data.to_json)
      expect(last_response.status).to eq 400
    end

    it "should return first app in paid apps in weather category (6001)" do
      get "/categories/6001/apps/paid/1"

      expect(last_response.body).to eq(app1.to_json)
      expect(last_response.status).to eq 200
    end

    it "should return error if app cannot be found by rank position" do
      data = { errors: 'Rank position is out of scope' }
      get "/categories/6001/apps/paid/5"

      expect(last_response.body).to eq(data.to_json)
      expect(last_response.status).to eq 400
    end

    it "should return third app in free apps in weather category (6001)" do
      get "/categories/6001/apps/free/3"

      expect(last_response.body).to eq(app7.to_json)
      expect(last_response.status).to eq 200
    end

    it "should return second app in grossing apps in weather category (6001)" do
      get "/categories/6001/apps/grossing/2"

      expect(last_response.body).to eq(app3.to_json)
      expect(last_response.status).to eq 200
    end
  end

  describe 'list of publishers by category, monetization, sorted by apps amount' do
    it "should return error if monetization is invalid" do
      get "/categories/6001/apps/fjg/publishers"

      expect(last_response.status).to eq 404
    end

    it "should return error if category id is invalid" do
      get "/categories/uiuy/apps/free/publishers"

      expect(last_response.status).to eq 404
    end

    it "should return bad request error" do
      data = { errors: 'App store error' }
      get "/categories/90/apps/paid/publishers"

      expect(last_response.body).to eq(data.to_json)
      expect(last_response.status).to eq 400
    end

    it "should return array of paid apps in weather category (6001)" do
      publishers = [{publisher_id: 2434, publisher_name: 'Yelp', rank: 1, apps_amount: 1, apps: ['App1'] }]
      get "/categories/6001/apps/paid/publishers"

      expect(last_response.body).to eq(publishers.to_json)
      expect(last_response.status).to eq 200
    end

    it "should return array of free apps in weather category (6001)" do
      publishers = [{publisher_id: 5678, publisher_name: 'Fizz', rank: 1, apps_amount: 3, apps: ['App6', 'App7', 'App8'] },
        {publisher_id: 9123, publisher_name: 'GoingApps', rank: 2, apps_amount: 2, apps: ['App5', 'App9'] },
        {publisher_id: 2434, publisher_name: 'Yelp', rank: 3, apps_amount: 1, apps: ['App4'] }
      ]
      get "/categories/6001/apps/free/publishers"

      expect(last_response.body).to eq(publishers.to_json)
      expect(last_response.status).to eq 200
    end

    it "should return array of grossing apps in weather category (6001)" do
      publishers = [{publisher_id: 5678, publisher_name: 'Fizz', rank: 1, apps_amount: 1, apps: ['App2'] },
        {publisher_id: 9123, publisher_name: 'GoingApps', rank: 2, apps_amount: 1, apps: ['App3'] },
      ]
      get "/categories/6001/apps/grossing/publishers"

      expect(last_response.body).to eq(publishers.to_json)
      expect(last_response.status).to eq 200
    end
  end
end