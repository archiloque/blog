require 'rouge' unless defined? ::Rouge.version
require 'rouge/themes/base16.rb'

class Rouge::Themes::Base16::Solarized
  style Text, :fg => '#002129'
  style Operator, Punctuation, :fg => '#002129', bold: true
end
