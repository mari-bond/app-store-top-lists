require "spec_helper"
require "./app/apps_fetcher"
require "./app/app"

RSpec.describe AppsFetcher do
  let(:app1) { build(:app) }
  let(:app2) { build(:app) }
  let(:app3) { build(:app) }
  let(:app4) { build(:app) }
  let(:app5) { build(:app) }

  describe 'fetch top' do
    let(:category) { '6001' }
    let(:monetization) { 'grossing' }

    it 'should retrieve from storage' do
      apps = [app1, app3]
      allow(App).to receive(:top).with(category, monetization).and_return(apps)

      expect(AppsFetcher.new(category, monetization).fetch_top).to eq apps
    end

    it 'should fetch from appstore' do
      target_apps = [app2, app4]
      target_app_ids = target_apps.map(&:id)
      target_apps_metadata = target_apps.to_json
      list = { paid: [app5.id], grossing: target_app_ids, free: [app1.id, app3.id] }
      data = top_apps_response(list).to_json
      fetcher = AppsFetcher.new(category, monetization)

      allow(App).to receive(:top).with(category, monetization).and_return([])
      allow(App).to receive(:save_top_list).with(category, list)
      allow(App).to receive(:save).with(target_apps)
      allow_any_instance_of(AppstoreClient).to receive(:top).with(category).and_return(data)
      allow_any_instance_of(AppstoreClient).to receive(:lookup).with(target_app_ids).and_return(target_apps_metadata)
      allow_any_instance_of(AppstoreParser).to receive(:parse_top_list).with(data).and_return(list)
      allow_any_instance_of(AppstoreParser).to receive(:parse_search_list).with(target_apps_metadata).and_return(target_apps)

      expect(fetcher.fetch_top).to eq(target_apps)
      expect(App).to have_received(:save).with(target_apps)
      expect(App).to have_received(:save_top_list).with(category, list)
    end
  end

  describe 'find top app by category, monetization and rank position' do
    let(:category) { '6001' }
    let(:monetization) { 'grossing' }
    let(:fetcher) { AppsFetcher.new(category, monetization) }

    it 'should return app by rank' do
      apps = [app1, app3, app5]
      allow(fetcher).to receive(:fetch_top).and_return apps

      expect(fetcher.top_by_rank('3')).to eq app5
      expect(fetcher.top_by_rank('1')).to eq app1
    end

    it 'should return error if rank is out of scope' do
      apps = [app1, app3, app5]
      allow(fetcher).to receive(:fetch_top).and_return apps

      expect(fetcher.top_by_rank('7')).to eq(nil)
    end

    it 'should return nil if no apps fetched' do
      allow(fetcher).to receive(:fetch_top).and_return []

      expect(fetcher.top_by_rank('2')).to eq(nil)
    end
  end

  it 'should fetch top apps publishers by category and monetization' do
    fetcher = AppsFetcher.new('6001', 'grossing')
    publishers = [{publisher_id: '5678', publisher_name: 'Fizz', rank: 1, apps_amount: 3, apps: ['App6', 'App7', 'App8'] },
      {publisher_id: '9123', publisher_name: 'GoingApps', rank: 2, apps_amount: 2, apps: ['App5', 'App9'] },
      {publisher_id: '2434', publisher_name: 'Yelp', rank: 3, apps_amount: 1, apps: ['App4'] }
    ]
    apps = [app1, app5]
    allow(fetcher).to receive(:fetch_top).and_return apps
    allow(App).to receive(:top_publishers).with(apps).and_return publishers

    expect(fetcher.fetch_publishers).to eq publishers
  end
end