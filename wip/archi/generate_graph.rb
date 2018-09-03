#!/usr/bin/env ruby

require 'json'

skills = JSON.parse(File.read('skills.json'))
RESULT = File.open('skills.gv', 'w')

def w(text)
  RESULT << "#{text}\n"
end

themes_to_index = {}
themes_to_skills = {}
skills_names_to_skill = {}

LEVELS_NAMES = [
  'Beginner',
  'Experienced',
  'Advanced'
]

def levels_block(separator)
  w ''
  w "\t{"
  LEVELS_NAMES.each_with_index do |level, index|
    w "\t\tlevel#{separator}#{index + 1}[label=\"#{level}\",shape=\"plaintext\"];"
  end
  1.upto(LEVELS_NAMES.length - 1) do |i|
    w "\t\tlevel#{separator}#{i} -> level#{separator}#{i + 1};"
  end
  w "\t}"
  w ''
end

skill_index = 0

skills.each do |skill|
  skill['index'] = skill_index
  theme_name = skill['theme']
  skills_names_to_skill[skill['name']] = skill
  unless themes_to_index.key?(theme_name)
    themes_to_index[theme_name] = themes_to_index.length
    themes_to_skills[theme_name] = []
  end
  themes_to_skills[theme_name] << skill
  skill_index += 1
end

# Manage the dependencies between skills
skills.each do |skill|
  if skill.key? 'require'
    required_skills_names = skill['require']
    skill['required_skills'] = required_skills_names.collect do |required_skill_name|
      required_skill = skills_names_to_skill[required_skill_name]
      unless required_skill
        raise "Unknown required skill [#{required_skill_name}]"
      end
      required_skill
    end
  end
end

w 'digraph skills {'
w "\trankdir=LR"
w "\tnewrank=true"
w ''

w "\tsubgraph cluster_skill_details {"
w "\t\tgraph[style=bold];"
skills.select do |skill|
  skill.key?('description')
end.sort{|a, b| a['name'] <=> b['name']}.each do |skill|
  w "\t\tdescription_#{skill['index']}[label=\"#{skill['name']}: #{skill['description']}\",shape=plaintext];"
end
w "\t\tfontsize=24;"
w "\t\tlabel=\"Skills Descriptions\";"
w "\t}"

levels_block('_')

skills.each do |skill|
  description = skill.key?('description') ? '*' : ''
  w "\tskill_#{skill['index']}[label=\"#{skill['name']}#{description}\",id=\"skill_#{skill['index']}\"];"
end

w ''

1.upto(LEVELS_NAMES.length) do |level|
  skills_for_level = skills.select do |skill|
    skill['level'] == level
  end.collect do |skill|
    "skill_#{skill['index']}"
  end
  w "\t{ rank=same; level_#{level}; level__#{level}; #{skills_for_level.join('; ')} }"
end

w ''

themes_to_index.each_pair do |theme_name, theme_index|
  w "\tsubgraph cluster_#{theme_index} {"
  w "\t\tlabel=\"#{theme_name}\";"
  themes_to_skills[theme_name].each do |skill|
    w "\t\tskill_#{skill['index']};"
  end
  w "\t}"
end

w ''

# Dependencies
skills.each do |skill|
  if skill.key? 'required_skills'
    skill['required_skills'].each do |required_skill|
      w "\tskill_#{required_skill['index']} -> skill_#{skill['index']};"
    end
  end
end

levels_block('__')

w "\tlabelloc=\"t\";"
w "\tfontsize=48;"
w "\tlabel=\"What should an IS architect know?\";"

w '}'
w ''

RESULT.close

`dot -Tsvg  skills.gv -o skills.svg`
`dot -Tpng  skills.gv -o skills.png`
