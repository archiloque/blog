require 'json'
source = JSON.parse(File.read('skills_origin.json'))
result = []
source.values.each do |entry|
  if entry['Level'] != ''
    result << {
      name: entry['Skill'],
      theme: entry['Theme'],
      level: entry['Level']
    }
  end
end
result.sort!{|a, b| a[:level]<=>b[:level]}
File.write('skills.json',JSON.pretty_generate(result))
