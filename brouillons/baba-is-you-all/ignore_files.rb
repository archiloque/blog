#!/usr/bin/env ruby

# Generate the ignore files list
full_list = Dir.glob('*.*')
full_list.select! do |file_name|
    extension = File.extname(file_name)
    case extension
    when '.asciidoc'
        file_name != 'README.asciidoc'
    when '.java'
        true
    when '.txt'
        true
    when '.pdf'
        file_name != 'README.pdf'
    when '.html'
        file_name != 'README.html'
    when '.mmd'
        true
    when '.svg'
        false
    when '.png'
        mmd_exist = File.exist?("#{File.basename(file_name,'.png')}.mmd")
        mmd_exist
    else
        raise "Unknown extension [#{extension}]"
    end
end
STDOUT << ":ignore_files: #{full_list.sort.join(', ')}\n"
