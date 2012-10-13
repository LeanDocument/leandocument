module Leandocument
  class Markdown < Render
    def to_html
      RDiscount.new(exec_trans).to_html
    end
    
    # Convert to something from content.
    # Currently, Change indent level.
    # TODO support plugin and expand format.
    # ==== Return
    # Text content.
    def exec_trans
      content = indented_content
      content = content.gsub(/^!\[(.*)\]\((.*)\)/, '![\\1]('+self.path+'\\2)') # For image
      content = content.gsub(/^(#+)(.*)$/, '\\1<a name="'+toc_hash('\\2')+'"></a>' + '\\2')
      content
    end
    
    def indented_content
      content = analyse_content
      self.indent.times do |i|
        content = content.to_s.gsub(/^#/, "##")
      end
      content
    end
    
    def toc
      return self.p_toc if self.p_toc
      self.p_toc = []
      unless self.indent == 0
        self.p_toc << {:level => self.indent, :title => self.title, :hash => toc_hash(self.title)}
      end
      indented_content.split(/\r\n|\r|\n/).each do |line|
        if line =~ /^(#+)(.*)$/
          self.p_toc << {:level => $1.length, :title => $2, :hash => toc_hash($2)}
        end
      end
      self.p_toc
    end
  end
end
