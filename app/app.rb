class App
  @@attributes = [:id, :name, :description, :icon_url, :publisher_id,
    :publisher_name, :price, :version, :rating
  ].freeze

  attr_accessor *@@attributes

  def initialize(params = {})
    params.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def [](attribute)
    send(attribute)
  end

  def []=(attribute, value)
    send("#{attribute}=", value)
  end

  def attributes
    attrs = {}
    self.class.attributes.each{ |a| attrs[a.to_s] = self[a].to_s }

    attrs
  end

  def attributes=(attrs)
    attrs.each{ |key, value| self[key] = value }
  end

  def save
    redis_data = []
    self.class.attributes.each do |attribute|
      redis_data << attribute
      redis_data << self[attribute]
    end
    $redis.hmset(app_key, *redis_data)
  end

  def app_key
    ['app', id].join(':')
  end

  class << self
    def attributes
      @@attributes
    end

    def find(id)
      app = new(id: id)
      attributes = $redis.hgetall(app.app_key)
      if attributes.any?
        app.attributes = attributes
      else
        app = nil
      end

      app
    end

    def top(category_id, monetization)
      $redis.lrange(top_list_key(category_id, monetization), 0, 200)
      .map{ |app_id| find(app_id) }
      .compact
    end

    def top_publishers(apps)
      publishers = []
      apps.group_by(&:publisher_id).each do |publisher_id, apps|
        publishers << {
          publisher_id: publisher_id,
          publisher_name: apps.first.publisher_name,
          rank: 0,
          apps_amount: apps.count,
          apps: apps.map(&:name)
        }
      end
      publishers.sort_by!{ |data| -data[:apps_amount] }
      publishers.map.with_index{ |publisher, index| publisher[:rank] = index + 1 }

      publishers
    end

    def save_top_list(category_id, list)
      list.each do |monetization, app_ids|
        key = top_list_key(category_id, monetization)
        app_ids.each{ |app_id| $redis.rpush(key, app_id) }
      end
    end

    def save(apps)
      apps.each{ |app| app.save }
    end

    def top_list_key(category_id, monetization)
      ['top', category_id, monetization].join('_')
    end
  end
end