module Leandocument
  class Render
    attr_accessor :content, :indent, :path, :p_toc
    def initialize(options = {})
      puts "Call render"
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
    
    def toc_hash(title)
      Digest::MD5.hexdigest(self.path + title)
    end
    
    def title
      content_ary[0]
    end
  end
end
