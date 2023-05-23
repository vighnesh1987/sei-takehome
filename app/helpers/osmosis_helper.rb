module OsmosisHelper
  def make_request(path, success_handler, error_handler)
    url = URI.parse("https://rpc.osl.zone#{path}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    puts "making request to #{url}"

    request = Net::HTTP::Get.new(url.request_uri)
    response = http.request(request)

    if response.code == '200'
      success_handler.call(JSON.parse(response.body))
    else
      error_handler.call(JSON.parse(response.body))
    end
  end
end
