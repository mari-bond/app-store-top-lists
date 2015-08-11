require_relative 'app'

class AppstoreParser
  MONETIZATION_CODES = {
    27 => :free,
    30 => :paid,
    38 => :grossing
  }.freeze

  # Parse appstore top apps data.
  # Returns app ids grouped by monetization
  def parse_top_list(data)
    parsed_data = {}

    if data.is_a?(Hash) && data['topCharts']
      data['topCharts'].each do |top_chart|
        monetization_code = top_chart['id'].to_i
        monetization = MONETIZATION_CODES[monetization_code]
        parsed_data[monetization] = top_chart['adamIds']
      end
    end

    parsed_data
  end

  # Parse appstore apps data.
  # Returns array of App objects.
  def parse_search_list(data)
    return [] unless data.is_a?(Hash) && data['results']
    data['results'].map do |app_data|
      App.new(
        id: app_data['trackId'],
        name: app_data['trackName'],
        description: app_data['description'],
        icon_url: app_data['artworkUrl60'],
        publisher_name: app_data['artistName'],
        publisher_id: app_data['artistId'],
        price: app_data['price'],
        version: app_data['version'],
        rating: app_data['averageUserRating']
      )
    end
  end
end