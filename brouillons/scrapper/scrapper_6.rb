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

# Télécharge le contenu d'une URL et renvoie son contenu
# @param [Addressable::URI] url
# @return [String]
def download_url_content(url)
  response = Curl.get(url) do |http|
    # Je suis un navigateur web !
    http.headers['User-Agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0'
  end
  response.body_str
end

# Calcule le nom du fichier correspondant à une URL
# @param [Addressable::URI] absolute_url
# @param [String] default_extension
# @return [String]
def calculate_file_name(absolute_url, default_extension)
  hexadecimal_codepoints = absolute_url.to_s.chars.map do |character|
    character.ord.to_s(16)
  end
  extension = File.extname(absolute_url.path)
  if extension.empty?
    extension = default_extension
  end
  "#{hexadecimal_codepoints.join('-')}#{extension}"
end

# Retourne le chemin complet vers le fichier
# @param [String] file_name
# @return [String, nil]
def full_file_path(file_name)
  File.join(TARGET_DIRECTORY, file_name)
end

# Retourne le chemin complet vers le fichier, ou nil si le fichier est déjà là
# @param [String] file_name
# @return [String, nil]
def download_path(file_name)
  target_file_path = full_file_path(file_name)
  if File.exists?(target_file_path)
    nil
  else
    target_file_path
  end
end

# @param [Addressable::URI] html_page_url
# @param [String] resource_url
# @param [String] default_extension
# @return [String]
def scrape_resource(html_page_url, resource_url, default_extension = '')
  # Assure d'avoir une URL absolue en combinant l'adresse de l'image
  # avec celle de la page
  absolute_url = html_page_url.join(resource_url).normalize
  puts "Vérifie la ressource [#{absolute_url}]"

  file_name = calculate_file_name(absolute_url, default_extension)
  target_file_path = download_path(file_name)
  if target_file_path
    puts "Télécharge [#{absolute_url}] à [#{target_file_path}]"
    IO.write(target_file_path, download_url_content(absolute_url))
    # Attendre un peu
    sleep(1)
  end
  file_name
end

PARSED_MAIN_URL = Addressable::URI.parse(MAIN_URL)

waiting_pages_urls = [
  PARSED_MAIN_URL
]

until waiting_pages_urls.empty?
  current_page_url = waiting_pages_urls.shift
  puts "Page [#{current_page_url}]"
  current_page_file_name = "#{calculate_file_name(current_page_url, '.html')}"
  current_page_file_path = download_path(current_page_file_name)
  if current_page_file_path
    doc = Nokogiri::HTML(download_url_content(current_page_url))

    doc.css('img').each do |image|
      image['src'] = scrape_resource(current_page_url, image['src'])
    end

    doc.css('link').each do |link|
      # Télécharge seulement les feuilles de styles externes
      if (link['rel'] == 'stylesheet') && link.key?('href')
        link['href'] = scrape_resource(current_page_url, link['href'], '.css')
      end
    end

    doc.css('script').each do |script|
      # Télécharge seulement les scripts externes
      if script.key?('src')
        script['src'] = scrape_resource(current_page_url, script['src'], '.js')
      end
    end

    doc.css('a').each do |a|
      if a.key?('href')
        href = a['href']
        absolute_href = current_page_url.join(href).normalize
        # Télécharge seulement les pages qui sont sur le même nom d'hôte
        if PARSED_MAIN_URL.host == absolute_href.host
          puts "Lien vers une autre page trouvé [#{absolute_href}]"
          a['href'] = "#{calculate_file_name(absolute_href, '.html')}"
          waiting_pages_urls << absolute_href
        else
          puts "Lien externe [#{absolute_href}]"
        end
      end
    end
    puts "Écrit [#{current_page_url}] at [#{current_page_file_path}]"
    IO.write(current_page_file_path, doc.to_html)
  end
end
