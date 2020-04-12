#!/usr/bin/env ruby

require 'nokogiri'
require 'fileutils'

CONSEILLE = 'con'
ENVIE = 'env'
CARRIERE = 'car'
RECOMPENSE = 'rec'
BON = 'bon'

ELEMENTS = [CONSEILLE, ENVIE, CARRIERE, RECOMPENSE, BON]

FILE_01 = "01-envie"
FILE_02 = "02-carriere"
FILE_03 = "03-bon"
FILE_04 = "04-recompense"
FILE_05 = "05-conseille"
FILE_06 = "06-complet"
FILE_07 = "07-milieu"

FILES = [
    FILE_01,
    FILE_02,
    FILE_03,
    FILE_04,
    FILE_05,
    FILE_06
]

BASE_DOCUMENT = Nokogiri::XML(IO.read('base.xml'))

def delete_ellipse_except(document, *list)
  (ELEMENTS - list).each do |e|
    document.at_css("##{e}").remove
  end
end

def delete_text_except(document, *list)
  (ELEMENTS - list).each do |e|
    document.css(".t#{e}").remove
  end
end

def delete_clip_except(document, *list)
  (ELEMENTS - list).each do |e|
    document.at_css("#c#{e}").remove
  end
end

def delete_mask_except(document, *list)
  (ELEMENTS - list).each do |e|
    document.at_css("#m#{e}").remove
  end
end

def create_clip(document, clip_source, *list)
  source_element = document.at_css("##{clip_source}")
  element = source_element.dup
  element.parent = source_element.parent
  element.delete('id')
  element.delete('style')
  element['class']='intersection'
  list.each do |e|
    element = element.replace("<g style=\"clip-path:url('#c#{e}');\">#{element.to_xml}</g>").first
  end
  document.at_css('style').content =  document.at_css('style').content + "
  .intersection {
      fill:#ff0000;
      fill-opacity:1;
    }"
end

def write(document, path)
  File.write("#{path}.svg", document.to_xml)
end

def fist_thing(name, file)
  base = BASE_DOCUMENT.dup
  delete_ellipse_except(base, name)
  delete_text_except(base, name)
  delete_clip_except(base)
  delete_mask_except(base)
  File.write("#{file}.svg", base.to_xml)
end

system("inkscape --without-gui --export-png=#{File.expand_path("base.png")} --file=#{File.expand_path("base.xml")}")

fist_thing(ENVIE, FILE_01)
fist_thing(CARRIERE, FILE_02)
fist_thing(BON, FILE_03)
fist_thing(RECOMPENSE, FILE_04)
fist_thing(CONSEILLE, FILE_05)

base = BASE_DOCUMENT.dup
delete_clip_except(base)
delete_mask_except(base)
File.write("#{FILE_06}.svg", base.to_xml)

base = BASE_DOCUMENT.dup
delete_mask_except(base)
delete_clip_except(base, ENVIE, RECOMPENSE, BON, CARRIERE)
create_clip(base, CONSEILLE, ENVIE, RECOMPENSE, BON, CARRIERE)
write(base, FILE_07)

system("svgo *.svg --disable=inlineStyles")

FILES.each do |file|
  IO.write("#{file}.svg", "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>#{IO.read("#{file}.svg")}")
end