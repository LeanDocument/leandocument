module Leandocument
  class ReStructuredText < Render
    def to_html
      html = RbST.new(exec_trans).to_html
      6.times do |i|
        html = html.gsub("<h#{6 - i}", "<h#{5 - i + indent}").gsub("</h#{6 - i}>", "</h#{5 - i + indent}>")
      end
      html
    end
    
    # Convert to something from content.
    # Currently, Change indent level.
    # TODO support plugin and expand format.
    # ==== Return
    # Text content.
    def exec_trans
      content = indented_content
      content = content.gsub(/^\.\. image:: (.*)$/, '.. image:: '+self.path+'\\1') # For image
    end
    
    def indented_content
      content = analyse_content
      unless self.indent == 1
        content = "#{"="*30}\n#{title}\n#{"="*30}\n\n#{content}"
      end
    end
  end
end
