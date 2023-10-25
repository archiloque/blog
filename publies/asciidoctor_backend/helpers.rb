require `'set`'

module Asciidoctor

  # Fake template
  class DebuggerTemplate
    def render(scope, params)
      `'`'
    end
  end

  # Patch the converter
  class Converter::TemplateConverter

    # Handle anything, just ask!
    def handles?(name)
      unless @templates.key? name
        @templates[name] = DebuggerTemplate.new
      end
      true
    end

    def convert(node, template_name = nil, opts = {})
      @lines ||= Set.new
      log_line =  nil
      value = nil
      if node.is_a? Asciidoctor::Block
        value = node.content
        log_line =
          "#{node.class} uses #{template_name} for #{node.context}"
      elsif node.is_a? Asciidoctor::AbstractBlock
        value = node.content
        log_line =
          "#{node.class} uses #{template_name}"
      elsif node.is_a? Asciidoctor::Inline
        value = node.text
        log_line =
          "#{node.class} uses #{template_name}"
      else
        raise "Can convert #{node.class}"
      end
      if @lines.add?(log_line)
        p log_line
      end
      value
    end

  end
end
