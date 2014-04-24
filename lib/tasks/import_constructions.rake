# encoding: UTF-8
task :import_constructions => :environment do
  urls = ['http://baustellen.offenes-aachen.de/api/sites.json']
  urls.each do |url|
    uri = URI(url)
    request = Net::HTTP::Get.new(uri)
    response = Net::HTTP.start(uri.hostname, uri.port) do |conn|
      conn.request(request)
    end
    puts response.body
    JSON.parse(response.body).each do |item|
      puts item
      model = Construction.find_or_initialize_by__id(item['_id'])
      model.update_attributes!(content: item['description'], subtitle: item['subtitle'], long: item['lng'], lat: item['lat'], start_date: item['start_date'], end_date: item['end_date'], last_updated: item['last_updated'], _id: item['_id'], organisation: item['organisation'], title: item['name'], approx_timeframe: item['approx_timeframe'], exact_position: ['exact_position'], city: item['city'], sidewalk_only: item['sidewalk_only'])
    end
  end
end