def top_apps_response(app_ids)
  {
    "topCharts":
    [
      {
        "adamIds": app_ids[:paid],
        "shortTitle":"Paid",
        "id":"30",
        "title":"Top Paid iPhone Apps",
      },
      {
        "adamIds": app_ids[:grossing],
        "shortTitle":"Top Grossing",
        "id":"38",
        "title":"Top Grossing iPhone Apps",
      },
      {
        "adamIds": app_ids[:free],
        "shortTitle":"Free",
        "id":"27",
        "title":"Top Free iPhone Apps",
      }
    ]
  }
end

def stub_top_requests(stub, app_ids)
  response =  top_apps_response(app_ids)
  path = 'https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewTop?'
  stub.get(path + 'dataOnly=true&genreId=6001&l=en&popId=30') { |env| [200, {}, response.to_json] }
  stub.get(path + 'dataOnly=true&genreId=90&l=en&popId=30') { |env| [400, {}, {'error' => 'Some error'}.to_json] }
end

def stub_lookup_requests(stub, grouped_apps)
  grouped_apps.each do |group, apps|
    results = apps.map do |app|
      {
        'trackId' => app[:id],
        'trackName' => app[:name],
        'description' => app[:description],
        'artworkUrl60' => app[:icon_url],
        'artistName' => app[:publisher_name],
        'artistId' => app[:publisher_id],
        'price' => app[:price],
        'version' => app[:version],
        'averageUserRating' => app[:rating]
      }
    end
    response = {"resultCount": apps.count, "results": results}
    lookup_str = apps.map{ |app| app[:id] }.join(',')
    stub.get("https://itunes.apple.com/lookup?id=#{lookup_str}") { |env| [200, {}, response.to_json] }
  end
end