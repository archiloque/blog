#!/usr/bin/env ruby

require 'fileutils'

require 'addressable'
require 'curl'

INITIAL_URL = 'https://queue.acm.org'
TARGET_DIRECTORY = 'download'

# Supprime le répertoire de destination s'il existe et le recréé
if File.exists?(TARGET_DIRECTORY)
  puts "Supprime [#{TARGET_DIRECTORY}]"
  FileUtils.remove_entry_secure(TARGET_DIRECTORY)
end
puts "Créé [#{TARGET_DIRECTORY}]"
Dir.mkdir(TARGET_DIRECTORY)

# tag::download[]
puts "Télécharge [#{INITIAL_URL}]"
parsed_url = Addressable::URI.parse(INITIAL_URL)
response = Curl.get(parsed_url) do |http|
  # Je suis un navigateur web !
  http.headers['User-Agent'] =
    'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0'
end

IO.write(File.join(TARGET_DIRECTORY, 'index.html'), response.body_str)
# end::download[]
