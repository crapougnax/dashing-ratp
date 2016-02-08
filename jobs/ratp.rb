require 'net/http'
require 'json'

id = 'ratp'

lines = {
  'RER A'   => ['rer','A'],
  'RER E'   => ['rer','B'],
  'Ligne 1' => ['metro','1'],
  'Ligne 7' => ['metro','7'],
  'Ligne 11' => ['metro','11'],
  'Tramway 2' => ['tram','2'],
}

$match = {
	'metro' => 'metros',
	'rer' => 'rers',
	'tram' => 'tramways'
}

def callEndpoint(type,id)
  http = Net::HTTP.new('api-ratp.pierre-grimaud.fr')
  return JSON.parse(http.request(Net::HTTP::Get.new("/v2/traffic/#{type}/#{id}")).body)
end

SCHEDULER.every '120s', :first_in => 0 do |job|
  items = []
  lines.each do |name, data|
    j = callEndpoint($match[data[0]], data[1])
    items << { 
      label: name, 
      value: j['response']['title'], 
      line: data[0] + ' ligne' + data[1], symbol: data[0] + ' symbole' 
    }
  end
  
  send_event(id, { title: "Trafic RATP", items: items })
  
end
