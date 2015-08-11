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
end