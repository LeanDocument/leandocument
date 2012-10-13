module Leandocument
  class Render
    attr_accessor :content, :indent, :path, :p_toc
    def initialize(options = {})
      self.content = options[:content]
      self.indent  = options[:indent]
      self.path    = options[:path]
    end
    
    def analyse_content
      content = content_ary[1..-1].join("\n")
    end
    
    def content_ary
      content.split(/\r\n|\r|\n/)
    end
    
    def title
      content_ary[0]
    end
  end
end
