#!/usr/bin/env ruby

require 'net/http'
require 'fileutils'

require 'addressable'
require 'nokogiri'

MAIN_URL = 'https://queue.acm.org'
TARGET_DIRECTORY = 'download'

# Cleaning target directory if it exists and recreates it
if File.exists?(TARGET_DIRECTORY)
  puts "Deleting [#{TARGET_DIRECTORY}]"
  FileUtils.remove_entry_secure(TARGET_DIRECTORY)
end
puts "Creating [#{TARGET_DIRECTORY}]"
Dir.mkdir(TARGET_DIRECTORY)

puts "Downloading [#{MAIN_URL}]"
parsed_url = Addressable::URI.parse(MAIN_URL)
response = Net::HTTP.get_response(parsed_url)
doc = Nokogiri::HTML(response.body)

IO.write(File.join(TARGET_DIRECTORY, 'index.html'), doc.to_html)
