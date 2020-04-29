#!/usr/bin/env ruby

require 'nokogiri'
require 'fileutils'

CONSEILLE = 'con'
ENVIE = 'env'
CARRIERE = 'car'
RECOMPENSE = 'rec'
BON = 'bon'

CLIP = 'CLIP'
MASK = 'MASK'

ELEMENTS = [CONSEILLE, ENVIE, CARRIERE, RECOMPENSE, BON]
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

def create_clip(document, clip_source, *names)
  source_element = document.at_css("##{clip_source}")
  element = source_element.dup
  source_element.next = element
  element.parent = source_element.parent
  element.delete('id')
  element.delete('style')
  element['class'] = 'intersection'
  names.each do |names|
    element = element.replace("<g style=\"clip-path:url('#c#{names}');\">#{element.to_xml}</g>").first
  end
  document.at_css('style').content = document.at_css('style').content + "
  .intersection {
      fill:#ff0000;
      fill-opacity:1;
    }"
end

def create_mask(document, mask_source, elements)
  source_element = document.at_css("##{mask_source}")
  element = source_element.dup
  source_element.next = element
  element.delete('id')
  element.delete('style')
  element['class'] = 'masked'
  elements.each_pair do |name, type|
    if type == MASK
      element = element.replace("<g mask=\"url(#m#{name})\">#{element.to_xml}</g>").first
    elsif type == CLIP
      element = element.replace("<g style=\"clip-path:url('#c#{name}');\">#{element.to_xml}</g>").first
    else
      raise type
    end
  end
end

def write_svg(document, path)
  File.write("#{path}.svg", document.to_xml)
  # Add UTF-8 declaration back
  IO.write("#{path}.svg", "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>#{IO.read("#{path}.svg")}")
end

def single_element(name, file)
  document = BASE_DOCUMENT.dup
  delete_ellipse_except(document, name)
  delete_text_except(document, name)
  delete_clip_except(document)
  delete_mask_except(document)
  write_svg(document, file)
end

system("inkscape --without-gui --export-png=#{File.expand_path("base.png")} --file=#{File.expand_path("base.xml")}")

single_element(ENVIE, 'envie')
single_element(CARRIERE, 'carriere')
single_element(BON, 'bon')
single_element(RECOMPENSE, 'recompense')
single_element(CONSEILLE, 'conseille')

base = BASE_DOCUMENT.dup
delete_clip_except(base)
delete_mask_except(base)
write_svg(base, 'complet')

base = BASE_DOCUMENT.dup
delete_mask_except(base)
delete_clip_except(base, ENVIE, RECOMPENSE, BON, CARRIERE)
create_clip(base, CONSEILLE, ENVIE, RECOMPENSE, BON, CARRIERE)
write_svg(base, 'milieu')

base = BASE_DOCUMENT.dup
delete_ellipse_except(base, ENVIE, CARRIERE)
delete_text_except(base, ENVIE, CARRIERE)
delete_mask_except(base, CARRIERE)
delete_clip_except(base)
create_mask(base, ENVIE, CARRIERE => MASK)
write_svg(base, 'envie-pas-carriere')

base = BASE_DOCUMENT.dup
delete_ellipse_except(base, BON, RECOMPENSE)
delete_text_except(base, BON, RECOMPENSE)
delete_mask_except(base, RECOMPENSE)
delete_clip_except(base)
create_mask(base, BON, RECOMPENSE => MASK)
write_svg(base, 'bon-pas-recompense')

base = BASE_DOCUMENT.dup
delete_ellipse_except(base, BON, RECOMPENSE)
delete_text_except(base, BON, RECOMPENSE)
delete_mask_except(base, BON)
delete_clip_except(base)
create_mask(base, RECOMPENSE, BON => MASK)
write_svg(base, 'recompense-pas-bon')

base = BASE_DOCUMENT.dup
delete_ellipse_except(base, BON, ENVIE, CARRIERE)
delete_text_except(base, BON, ENVIE, CARRIERE)
delete_mask_except(base, ENVIE, CARRIERE)
delete_clip_except(base)
create_mask(base, BON, ENVIE => MASK, CARRIERE => MASK)
write_svg(base, 'bon-pas-envie-ni-carriere')

base = BASE_DOCUMENT.dup
delete_ellipse_except(base, BON, ENVIE, CARRIERE, RECOMPENSE)
delete_text_except(base, BON, ENVIE, CARRIERE, RECOMPENSE)
delete_mask_except(base, BON)
delete_clip_except(base, CARRIERE, ENVIE)
create_mask(base, RECOMPENSE, BON => MASK, ENVIE => CLIP)
create_mask(base, RECOMPENSE, BON => MASK, CARRIERE => CLIP)
write_svg(base, 'recompense-pas-bon-mais')

base = BASE_DOCUMENT.dup
delete_mask_except(base, ENVIE, CARRIERE, RECOMPENSE)
delete_clip_except(base, BON)
create_mask(base, CONSEILLE, ENVIE => MASK, CARRIERE => MASK, RECOMPENSE => MASK, BON => CLIP)
write_svg(base, 'conseille-bon-mais')

system("svgo *.svg --disable=inlineStyles")
