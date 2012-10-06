module Leandocument
  class Document
    attr_accessor :path, :lang, :settings, :base_path, :indent
    
    def initialize(options = {})
      self.lang = options[:lang]
      self.base_path = options[:base_path] || Dir.pwd
      self.indent = options[:indent] || 0
    end
    
    def file_path
      "#{self.base_path}/README.#{self.lang}.md"
    end
    
    def content
      File.exist?(self.file_path) ? open(self.file_path).read : ""
    end
    
    def markdown
      RDiscount.new(exec_trans(content))
    end
    
    def exec_trans(content)
      self.indent.times do |i|
        content = content.to_s.gsub(/^#/, "## ")
      end
      content
    end
    
    def d(f, path)
      return nil if [".", ".."].include?(f)
      return nil if f =~ /^\./
      expand_path = File.expand_path(f, path)
      File::ftype(expand_path) == "directory" ? expand_path : nil
    end
    
    def dirs(path)
      ary = Dir.entries(path).collect do |f|
        d(f, path)
      end
      ary.delete(nil)
      ary
    end
    
    def to_html
      page = markdown.to_html
      path = File.dirname(file_path)
      dirs(path).each do |dir|
        doc = Document.new :base_path => dir, :lang => self.lang, :indent => self.indent + 1
        page += doc.to_html
      end
      page
    end
  end
end
