#!/usr/bin/env ruby

require 'net/http'
require 'addressable'

MAIN_URL = 'http://example.com'

puts "Downloading [#{MAIN_URL}]"
parsed_url = Addressable::URI.parse(main_url)
response = Net::HTTP.get(parsed_url)
IO.write('index.html', response)
