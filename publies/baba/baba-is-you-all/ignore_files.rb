#!/usr/bin/env ruby

# Generate the ignore files list
file_list = Dir.glob('*.*')
file_list.select! do |file_name|
    extension = File.extname(file_name)
    case extension
    when '.asciidoc'
        file_name != 'README.asciidoc'
    when '.epub'
      file_name != 'Baba.epub'
    when '.sh'
        true
    when '.yml'
        true
    when '.rb'
        true
    when '.ttf'
        true
    when '.java'
        true
    when '.txt'
        true
    when '.json'
        true
    when '.pdf'
        file_name != 'Baba.pdf'
    when '.html'
        file_name != 'README.html'
    when '.mmd'
        true
    when '.svg'
        false
    when '.png'
        File.exist?("#{File.basename(file_name,'.png')}.mmd")
    else
        raise "Unknown extension [#{extension}]"
    end
end
STDOUT << ":ignore_files: #{file_list.sort.join(', ')}\n"
