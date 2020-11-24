#!/usr/bin/env ruby

require 'net/http'
require 'fileutils'

require 'addressable'
require 'nokogiri'

INITIAL_URL = 'https://queue.acm.org'
TARGET_DIRECTORY = 'download'

# Supprime le répertoire de destination s'il existe et le recréé
if File.exists?(TARGET_DIRECTORY)
  puts "Supprime [#{TARGET_DIRECTORY}]"
  FileUtils.remove_entry_secure(TARGET_DIRECTORY)
end
puts "Créé [#{TARGET_DIRECTORY}]"
Dir.mkdir(TARGET_DIRECTORY)

puts "Télécharge [#{INITIAL_URL}]"
parsed_url = Addressable::URI.parse(INITIAL_URL)
response = Net::HTTP.get(parsed_url)
doc = Nokogiri::HTML(response)

IO.write(File.join(TARGET_DIRECTORY, 'index.html'), doc.to_html)
