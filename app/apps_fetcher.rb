require_relative 'app'
require_relative 'appstore_client'
require_relative 'appstore_parser'

class AppsFetcher
  def initialize(category_id, monetization)
    @category_id = category_id
    @monetization = monetization
    @appstore_client = AppstoreClient.new
    @parser = AppstoreParser.new
  end

  def fetch_top
    apps = find_top
    apps.any? ? apps : fetch_top_from_appstore
  end

  def top_by_rank(rank)
    fetch_top[rank.to_i - 1]
  end

  private

  def find_top
    App.top(@category_id, @monetization)
  end

  def fetch_top_from_appstore
    data = @appstore_client.top(@category_id)
    list = @parser.parse_top_list(data)
    App.save_top_list @category_id, list
    apps = fetch_apps_metadata(list[@monetization.to_sym])

    apps
  end

  def fetch_apps_metadata(app_ids)
    return [] unless app_ids
    search_app_ids = app_ids.reject{ |app_id| !!App.find(app_id) }
    apps_metadata = @appstore_client.lookup(search_app_ids)
    apps = @parser.parse_search_list(apps_metadata)
    App.save apps

    apps
  end
end