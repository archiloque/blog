#!/usr/bin/env ruby

require 'net/http'
require 'addressable'

INITIAL_URL = 'http://example.com'

puts "Télécharge [#{INITIAL_URL}]"
parsed_url = Addressable::URI.parse(main_url)
response = Net::HTTP.get(parsed_url)
IO.write('index.html', response)
