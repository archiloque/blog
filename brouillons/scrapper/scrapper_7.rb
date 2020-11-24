#!/usr/bin/env ruby

require 'fileutils'
require 'set'

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

# @param [Addressable::URI] url
# @return [Hash] contient un :body et une :extension
def fetch_content(url)
  response = Curl.get(url) do |http|
    # Je suis un navigateur web !
    http.headers['User-Agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0'
  end
  extension = MIME::Types[response.content_type].first.preferred_extension
  {
    body: response.body_str,
    extension: extension
  }
end

# Retourne le chemin complet vers le fichier
# @param [String] file_name
# @return [String, nil]
def full_file_path(file_name)
  File.join(TARGET_DIRECTORY, file_name)
end

KNOWN_URLS = {}
# @param [Addressable::URI] html_page_url
# @param [String] resource_url
# @return [String]
def scrape_resource(html_page_url, resource_url, count, index)
  # Assure d'avoir une URL absolue en combinant l'adresse de la resource
  # avec celle de la page
  absolute_url = html_page_url.join(resource_url).normalize
  puts "\t#{index + 1}/#{count} Vérifie la ressource [#{absolute_url}]"

  if KNOWN_URLS.key?(absolute_url.to_s)
    KNOWN_URLS[absolute_url.to_s]
  else
    puts "\t\tTélécharge [#{absolute_url}]"
    content = fetch_content(absolute_url)
    save_content(absolute_url, content[:extension], content[:body])
  end
end

# @param [Addressable::URI] url
# @param [String] extension
# @param [String] content
def save_content(url, extension, content)
  file_name = "#{KNOWN_URLS.length}.#{extension}"
  target_file_path = File.join(TARGET_DIRECTORY, file_name)
  IO.write(target_file_path, content)
  KNOWN_URLS[url.to_s] = file_name

  # Attendre un peu
  sleep(1)
  file_name
end

PAGES_TO_PROCESS = Set.new

PARSED_INITIAL_URL = Addressable::URI.parse(INITIAL_URL)
content = fetch_content(PARSED_INITIAL_URL)
save_content(PARSED_INITIAL_URL, content[:extension], content[:body])
PAGES_TO_PROCESS.add(PARSED_INITIAL_URL)

# @param [String] current_page_url
# @param [Nokogiri::XML::Node] a
def scrape_link(current_page_url, a, count, index)
  href = a['href']
  absolute_href = current_page_url.join(href).normalize
  # Traite seulement les liens qui sont sur le même nom d'hôte
  if PARSED_INITIAL_URL.host == absolute_href.host
    puts "\t#{index + 1}/#{count} Lien interne trouvé [#{absolute_href}]"
    absolute_href_no_fragment = absolute_href.omit(:fragment)
    unless KNOWN_URLS.key?(absolute_href_no_fragment.to_s)
      puts "\t\tNouveau lien interne [#{absolute_href_no_fragment}]"
      content = fetch_content(absolute_href_no_fragment)
      save_content(absolute_href_no_fragment, content[:extension], content[:body])
      if content[:extension] == 'html'
        puts "\t\t\tNouvelle page à traiter [#{absolute_href_no_fragment}]"
        PAGES_TO_PROCESS.add(absolute_href_no_fragment)
      end
    end

    file = KNOWN_URLS[absolute_href_no_fragment.to_s]
    # Remet le fragment en fin d'URL s'il y en a un
    file_url = Addressable::URI.parse(file)
    file_url.fragment = absolute_href.fragment

    a['href'] = file_url.to_s
  else
    puts "\t#{index + 1}/#{count} Lien externe trouvé [#{absolute_href}]"
    a['href'] = absolute_href.to_s
  end
end

until PAGES_TO_PROCESS.empty?
  current_page_url = PAGES_TO_PROCESS.first
  PAGES_TO_PROCESS.delete(current_page_url)

  current_file_path = full_file_path(KNOWN_URLS[current_page_url.to_s])
  puts "Traite [#{current_page_url}] [#{current_file_path}] (reste #{PAGES_TO_PROCESS.length})"
  doc = Nokogiri::HTML(IO.read(current_file_path))

  images = doc.css('img')
  puts "\t#{images.length} images"
  images.each.with_index do |image, index|
    image['src'] = scrape_resource(current_page_url, image['src'], images.length, index)
  end

  css = doc.css('link')
  puts "\t#{css.length} css"
  css.each.with_index do |link, index|
    # Télécharge seulement les feuilles de styles externes
    if (link['rel'] == 'stylesheet') && link.key?('href')
      link['href'] = scrape_resource(current_page_url, link['href'], css.length, index)
    end
  end

  scripts = doc.css('script')
  puts "\t#{scripts.length} scripts"
  scripts.each.with_index do |script, index|
    # Télécharge seulement les scripts externes
    if script.key?('src')
      script['src'] = scrape_resource(current_page_url, script['src'], scripts.length, index)
    end
  end

  as = doc.css('a')
  puts "\t#{as.length} liens"
  as.each.with_index do |a, index|
    if a.key?('href')
      scrape_link(current_page_url, a, as.length, index)
    end
  end

  IO.write(current_file_path, doc.to_html)
end
