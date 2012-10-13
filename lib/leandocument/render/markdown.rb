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
    end
    
    def indented_content
      content = analyse_content
      self.indent.times do |i|
        content = content.to_s.gsub(/^#/, "##")
      end
      unless self.indent == 1
        content = "#{"#"*self.indent}#{title}\n#{content}"
      end
      content
    end
  end
end
