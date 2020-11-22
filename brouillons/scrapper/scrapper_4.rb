#!/usr/bin/env ruby

require 'net/http'
require 'fileutils'

require 'addressable'
require 'nokogiri'
require 'curl'

MAIN_URL = 'https://queue.acm.org'
TARGET_DIRECTORY = 'download'

# Supprime le répertoire de destination s'il existe et le recréé
if File.exists?(TARGET_DIRECTORY)
  puts "Supprime [#{TARGET_DIRECTORY}]"
  FileUtils.remove_entry_secure(TARGET_DIRECTORY)
end
puts "Créé [#{TARGET_DIRECTORY}]"
Dir.mkdir(TARGET_DIRECTORY)

# @param [Addressable::URI] url
# @return [String]
def download_url_content(url)
  response = Curl.get(url) do |http|
    # Je suis un navigateur web !
    http.headers['User-Agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0'
  end
  response.body_str
end

puts "Télécharge [#{MAIN_URL}]"
parsed_url = Addressable::URI.parse(MAIN_URL)
doc = Nokogiri::HTML(download_url_content(parsed_url))

# @param [Addressable::URI] html_page_url
# @param [String] resource_url
# @return [String]
def scrape_resource(html_page_url, resource_url)
  # Assure d'avoir une URL absolue en combinant l'adresse de la resource
  # avec celle de la page
  absolute_url = html_page_url.join(resource_url).normalize
  puts "Vérifie la ressource [#{absolute_url}]"

  hexadecimal_codepoints = absolute_url.to_s.chars.map do |character|
    character.ord.to_s(16)
  end
  file_name = "#{hexadecimal_codepoints.join('-')}#{File.extname(absolute_url.path)}"
  target_file_path = File.join(TARGET_DIRECTORY, file_name)
  unless File.exists?(target_file_path)
    puts "Télécharge [#{absolute_url}] to [#{target_file_path}]"
    IO.write(target_file_path, download_url_content(absolute_url))
    # Attendre un peu
    sleep(1)
  end
  file_name
end

doc.css('img').each do |image|
  image['src'] = scrape_resource(parsed_url, image['src'])
end

doc.css('link').each do |link|
  # Télécharge seulement les feuilles de styles externes
  if (link['rel'] == 'stylesheet') && link.key?('href')
    link['href'] = scrape_resource(parsed_url, link['href'])
  end
end

doc.css('script').each do |script|
  # Télécharge seulement les scripts externes
  if script.key?('src')
    script['src'] = scrape_resource(parsed_url, script['src'])
  end
end

IO.write(File.join(TARGET_DIRECTORY, 'index.html'), doc.to_html)
