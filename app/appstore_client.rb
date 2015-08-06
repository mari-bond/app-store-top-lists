require 'faraday'
require 'json'

class AppstoreClient
  def top(category_id)
    params = { genreId: category_id, popId: 30, dataOnly: true, l: 'en' }
    response = connection(top_connection_options)
      .get('WebObjects/MZStore.woa/wa/viewTop', params)

    parse_response response
  end

  def lookup(app_id)
    response = connection.get('lookup', { id: app_id })

    parse_response response
  end

  private

  def parse_response(response)
    if response && response.status == 200
      begin
        JSON.parse response.body
      rescue
      end
    end
  end

  def top_connection_options
    {
      headers: {
        # 'Accept-Encoding'     => 'gzip, deflate, sdch',
        'Accept-Language'     => 'en-US,en;q=0.8,lv;q=0.6',
        'User-Agent'          => 'iTunes/11.1.1 (Windows; Microsoft Windows 7 x64
          Ultimate Edition Service Pack 1 (Build 7601)) AppleWebKit/536.30.1',
        'Accept'              => 'text/html,application/xhtml+xml,application/xml;
          q=0.9,image/webp,*/*;q=0.8',
        'Cache-Control'       => 'max-age=0',
        'X­-Apple-Store-Front' => '143441-1,17'
      }
    }
  end

  def endpoint
    'https://itunes.apple.com/'
  end

  def connection(options = {})
    Faraday.new(endpoint, options) do |faraday|
      faraday.request  :url_encoded
      faraday.adapter  Faraday.default_adapter
    end
  end
end