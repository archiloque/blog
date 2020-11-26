#!/usr/bin/env ruby

require 'fileutils'
require 'set'

require 'addressable'
require 'nokogiri'
require 'curl'
require 'mime/types'

INITIAL_URL = 'https://queue.acm.org'
TARGET_DIRECTORY = 'download'
KNOWN_URLS_FILE_NAME = 'known_urls.txt'

unless File.exists?(TARGET_DIRECTORY)
  puts "Créé [#{TARGET_DIRECTORY}]"
  Dir.mkdir(TARGET_DIRECTORY)
end

# @return [Hash{String, String}]
def initial_known_urls
  if File.exists?(KNOWN_URLS_FILE_NAME)
    Hash.new(IO.readlines(KNOWN_URLS_FILE_NAME).map{ |l| l.split(' ')})
  else
    {}
  end
end

KNOWN_URLS = initial_known_urls

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

# Retourne le chemin complet vers le fichier
# @param [String] file_name
# @return [String]
def full_file_path(file_name)
  File.join(TARGET_DIRECTORY, file_name)
end

# @param [Addressable::URI] html_page_url
# @param [String] resource_url
# @return [String] le nom du fichier
def scrape_resource(html_page_url, resource_url)
  # Assure d'avoir une URL absolue en combinant l'adresse de la resource
  # avec celle de la page
  absolute_url = html_page_url.join(resource_url).normalize
  puts "Vérifie la ressource [#{absolute_url}]"

  if KNOWN_URLS.key?(absolute_url.to_s)
    KNOWN_URLS[absolute_url.to_s]
  else
    puts "Télécharge [#{absolute_url}]"
    content = fetch_content(absolute_url)
    save_content(absolute_url, content[:extension], content[:body])
  end
end

# @param [Addressable::URI] url
# @param [String] extension
# @param [String] content
# @return [String] le nom du fichier
def save_content(url, extension, content)
  file_name = "#{KNOWN_URLS.length}.#{extension}"
  target_file_path = File.join(TARGET_DIRECTORY, file_name)
  IO.write(target_file_path, content)
  KNOWN_URLS[url.to_s] = file_name
  IO.write(KNOWN_URLS_FILE_NAME, KNOWN_URLS.to_a.map { |l| l.join(' ') }.join("\n"))
  # Attendre un peu
  sleep(1)
  file_name
end

PARSED_INITIAL_URL = Addressable::URI.parse(INITIAL_URL)

# @return [Set]
def initial_pages_to_process
  if File.exists?(PAGES_TO_PROCESS_FILE_NAME)
    Set.new + IO.readlines(PAGES_TO_PROCESS_FILE_NAME).map{|l| Addressable::URI.parse(l)}
  else
    content = fetch_content(PARSED_INITIAL_URL)
    save_content(PARSED_INITIAL_URL, content[:extension], content[:body])
    Set.new + [PARSED_INITIAL_URL]
  end
end

PAGES_TO_PROCESS = initial_pages_to_process


# @param [String] current_page_url
# @param [String] resource_url
# @return [String]
def scrape_link(current_page_url, resource_url)
  absolute_url = current_page_url.join(resource_url).normalize
  # Traite seulement les liens qui sont sur le même nom d'hôte
  # On peut également filtrer les adresses des pages
  # dont on sait qu'elles ne nous intéressent pas
  if PARSED_INITIAL_URL.host == absolute_url.host
    puts "Lien interne trouvé [#{absolute_url}]"
    absolute_url_no_fragment = absolute_url.omit(:fragment)
    unless KNOWN_URLS.key?(absolute_url_no_fragment.to_s)
      puts "Nouveau lien interne [#{absolute_url_no_fragment}]"
      content = fetch_content(absolute_url_no_fragment)
      save_content(absolute_url_no_fragment, content[:extension], content[:body])
      if content[:extension] == 'html'
        puts "Nouvelle page à traiter [#{absolute_url_no_fragment}]"
        PAGES_TO_PROCESS.add(absolute_url_no_fragment)
      end
    end

    file = KNOWN_URLS[absolute_url_no_fragment.to_s]
    # Remet le fragment en fin d'URL s'il y en a un
    file_url = Addressable::URI.parse(file)
    file_url.fragment = absolute_url.fragment
    file_url.to_s
  else
    puts "Lien externe trouvé [#{absolute_url}]"
    absolute_url.to_s
  end
end

PAGES_TO_PROCESS_FILE_NAME = 'pages_to_process.txt'

until PAGES_TO_PROCESS.empty?
  current_page_url = PAGES_TO_PROCESS.first
  PAGES_TO_PROCESS.delete(current_page_url)
  IO.write(PAGES_TO_PROCESS_FILE_NAME, PAGES_TO_PROCESS.to_a.map { |u| u.to_s }.join("\n"))

  current_file_path = full_file_path(KNOWN_URLS[current_page_url.to_s])
  puts "Traite [#{current_page_url}] [#{current_file_path}]"
  doc = Nokogiri::HTML(IO.read(current_file_path))

  images = doc.css('img[src]')
  images.each.with_index do |image|
    image['src'] = scrape_resource(current_page_url, image['src'])
  end

  css = doc.css('link[rel=stylesheet][href]')
  css.each.with_index do |link|
    link['href'] = scrape_resource(current_page_url, link['href'])
  end

  scripts = doc.css('script[src]')
  scripts.each.with_index do |script|
    script['src'] = scrape_resource(current_page_url, script['src'])
  end

  as = doc.css('a[href]')
  as.each.with_index do |a|
    a['href'] = scrape_link(current_page_url, a['href'])
  end

  IO.write(current_file_path, doc.to_html)
end
