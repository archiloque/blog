#!/usr/bin/env ruby

require 'fileutils'

require 'addressable'
require 'nokogiri'
require 'curl'
require 'mime/types'

INITIAL_URL = 'https://queue.acm.org'
TARGET_DIRECTORY = 'download'

# Supprime le répertoire de destination s'il existe et le recréé
if File.exists?(TARGET_DIRECTORY)
  puts "Supprime [#{TARGET_DIRECTORY}]"
  FileUtils.remove_entry_secure(TARGET_DIRECTORY)
end
puts "Créé [#{TARGET_DIRECTORY}]"
Dir.mkdir(TARGET_DIRECTORY)

# tag::fetch_content[]
# @param [Addressable::URI] url
# @return [Hash] contient un :body et une :extension
def fetch_content(url)
  response = Curl.get(url) do |http|
    # Je suis un navigateur web !
    http.headers['User-Agent'] =
      'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0'
  end
  extension = MIME::Types[response.content_type].first.preferred_extension
  {
    body: response.body_str,
    extension: extension
  }
end
# end::fetch_content[]

puts "Télécharge [#{INITIAL_URL}]"
parsed_url = Addressable::URI.parse(INITIAL_URL)
doc = Nokogiri::HTML(fetch_content(parsed_url)[:body])

KNOWN_URLS = {}
# Localise les éléments img avec un attribut src
doc.css('img[src]').each do |image|
  image_src = image['src']
  # Assure d'avoir une URL absolue en combinant l'adresse de l'image
  # avec celle de la page si l'image a une adresse relative,
  # par exemple http://exemple.com +  lapin.png = http://exemple.com/lapin.png
  # si l'image a déjà une adresse absolue alors utilise celle là
  # Addressable::URI#normalize essaie de corriger les URls incorrectes, 
  # par exemple celles qui contiennent des espace
  image_url = parsed_url.join(image_src).normalize

  if KNOWN_URLS.key?(image_url.to_s)
    image_file_name = KNOWN_URLS[image_url.to_s]
  else
    # tag::scrape_images_internal[]
    puts "Télécharge [#{image_url}]"
    content = fetch_content(image_url)
    image_file_name = "#{KNOWN_URLS.length}.#{content[:extension]}"
    KNOWN_URLS[image_url.to_s] = image_file_name
    image_file_path = File.join(TARGET_DIRECTORY, image_file_name)
    IO.write(
      image_file_path,
      content[:body]
    )
    # end::scrape_images_internal[]
  end
  # Remplace l'URL d'origine par le nom du fichier
  image['src'] = image_file_name
end

IO.write(File.join(TARGET_DIRECTORY, 'index.html'), doc.to_html)
