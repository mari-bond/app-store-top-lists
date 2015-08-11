require "spec_helper"
require "./app/app"

RSpec.describe App do
  describe 'find app by id' do
    it 'should return app' do
      id = '236735'
      app = App.new id: id, name: 'Test'
      $redis.hmset("app:#{id}", :id, id, :name, 'Test')

      expect(App.find(id).attributes).to eq app.attributes
    end

    it 'should return nil' do
      expect(App.find('1111111')).to eq nil
    end
  end

  describe 'fetch top apps by category and monetization' do
    it 'should return apps' do
      app1 = build(:app)
      app2 = build(:app)
      app3 = build(:app)
      app4 = build(:app)
      store_key = "top_6001_free"
      store_key2 = "top_6011_free"
      store_key3 = "top_6001_paid"
      $redis.rpush(store_key, app1.id)
      $redis.rpush(store_key3, app3.id)
      $redis.rpush(store_key, app4.id)
      $redis.rpush(store_key2, app3.id)
      $redis.rpush(store_key2, app1.id)
      $redis.rpush(store_key, app2.id)
      allow(App).to receive(:find) do |app_id|
        [app1, app2, app4].select{ |app| app.id == app_id }.first
      end

      expect(App.top('6001', 'free')).to eq [app1, app4, app2]
    end

    it 'should return blank array' do
      expect(App.top('6001', 'free')).to eq []
    end
  end

  describe 'save top list of apps by some category and monetization to storage' do
    it 'should save app ids to storage' do
      App.save_top_list('6001', {free: ['1','2'], paid: ['4', '6'], grossing: ['5']})

      expect($redis.lrange('top_6001_paid', 0, 200)).to eq(['4', '6'])
      expect($redis.lrange('top_6001_free', 0, 200)).to eq(['1', '2'])
      expect($redis.lrange('top_6001_grossing', 0, 200)).to eq(['5'])
    end

    it 'should save nothing if no app ids passed' do
      App.save_top_list('6001', {})

      expect($redis.lrange('top_6001_paid', 0, 200)).to eq([])
      expect($redis.lrange('top_6001_free', 0, 200)).to eq([])
      expect($redis.lrange('top_6001_grossing', 0, 200)).to eq([])
    end
  end

  it 'should save apps' do
    app1 = build(:app)
    app2 = build(:app)
    app3 = build(:app)
    app4 = build(:app)
    apps = [app3, app4, app2]
    apps.each{ |app| allow(app).to receive(:save) }

    App.save(apps)

    apps.each{ |app| expect(app).to have_received(:save) }
  end

  describe 'top publishers' do
    let(:category) { '6001' }
    let(:monetization) { 'grossing' }

    it 'should return top publishers with apps names sorted by apps amount' do
      app1 = build(:app, publisher_id: '12345', publisher_name: 'test')
      app2 = build(:app, publisher_id: '55555', publisher_name: 'yelp')
      app3 = build(:app, publisher_id: '12345', publisher_name: 'test')
      app4 = build(:app, publisher_id: '9999', publisher_name: 'some')
      app5 = build(:app, publisher_id: '55555', publisher_name: 'yelp')
      app6 = build(:app, publisher_id: '55555', publisher_name: 'yelp')
      apps = [app1, app2, app3, app4, app5, app6]

      expect(App.top_publishers(apps)).to eq [
        {publisher_id: '55555', publisher_name: 'yelp', rank: 1, apps_amount: 3, apps: [app2.name, app5.name, app6.name] },
        {publisher_id: '12345', publisher_name: 'test', rank: 2, apps_amount: 2, apps: [app1.name, app3.name] },
        {publisher_id: '9999', publisher_name: 'some', rank: 3, apps_amount: 1, apps: [app4.name] }
      ]
    end

    it 'should return blank array if apps passed' do
      expect(App.top_publishers([])).to eq []
    end
  end
end