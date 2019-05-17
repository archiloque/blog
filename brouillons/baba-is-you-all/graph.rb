#!/usr/bin/env ruby

require 'fileutils'
require 'nokogiri'

mmd_path = ARGV[0]
title = (ARGV.length > 1) ? ARGV[1] : nil
full_mmd_path = File.expand_path(mmd_path)
graph_file_base_name = File.basename(full_mmd_path, '.mmd')
graph_file_name_no_extension = File.join(File.dirname(full_mmd_path), graph_file_base_name)
file_info_regex = /baba-is-you-(?<part_id>\d+)\/graph(?<graph_id>\d+).mmd/
file_info = file_info_regex.match(full_mmd_path)
part_id = file_info['part_id']
graph_id = file_info['graph_id']

svg_full_path = "#{graph_file_name_no_extension}.svg"
png_full_path = "#{graph_file_name_no_extension}.png"
asciidoc_full_path = "#{graph_file_name_no_extension}.asciidoc"

`mmdc -i #{full_mmd_path} -o #{svg_full_path} -c #{File.join(__dir__, 'mermaid-config.json')}`

svg_doc  = Nokogiri::XML(IO.read(svg_full_path))
svg_view_box = svg_doc.at('svg')['viewBox']
svg_regex = /\A0 0 (?<width>[\d.]+) (?<height>[\d.]+)\z/
svg_size = svg_regex.match(svg_view_box)
svg_height = svg_size['height'].to_f.ceil
svg_width = svg_size['width'].to_f.ceil

# to png
`URL=file:///#{svg_full_path} node screenshot.js`
# trim
`gm mogrify -trim screenshot.png`
png_size_text = `gm identify -format "%w %h" screenshot.png`.chop
png_regex = /\A(?<width>\d+) (?<height>\d+)\z/
png_size = png_regex.match(png_size_text)
png_height = png_size['height'].to_i / 2
png_width = png_size['width'].to_i / 2

FileUtils.mv('screenshot.png', png_full_path)

if ! title
content = <<-XXX
ifeval::["{doctype}" == "book"]
image::../baba-is-you-#{part_id}/graph#{graph_id}.png[width=#{png_width},height=#{png_height},align="center"]
endif::[]
ifeval::["{doctype}" != "book"]
image::../baba-is-you-#{part_id}/graph#{graph_id}.svg[width=#{svg_width},height=#{svg_height},align="center"]
endif::[]
XXX
else
content = <<-XXX
ifeval::["{doctype}" == "book"]
image::../baba-is-you-#{part_id}/graph#{graph_id}.png[title="#{title}",width=#{png_width},height=#{png_height},align="center"]
endif::[]
ifeval::["{doctype}" != "book"]
image::../baba-is-you-#{part_id}/graph#{graph_id}.svg[title="#{title}",width=#{svg_width},height=#{svg_height},align="center"]
endif::[]
XXX
end

File.open(asciidoc_full_path, 'w') {|f| f.write(content) }

STDOUT << "include::graph#{graph_id}.asciidoc[]\n"