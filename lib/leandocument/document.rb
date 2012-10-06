# LeanDocument::Document class is converter to text from file content for LeanDocument
#
# Usage:
# @doc = Document.new(:lang => "ja")
# puts @doc.to_html
module Leandocument
  class Document
    attr_accessor :path, :lang, :settings, :base_path, :indent
    
    # Generate Document class.
    # ==== Args
    # options :: lang:Default document language. base_path: Document path. indent: Document indent level.
    # ==== Return
    # New Leandocument Document class.
    def initialize(options = {})
      self.lang = options[:lang]
      self.base_path = options[:base_path] || Dir.pwd
      self.indent = options[:indent] || 0
    end
    
    # Generate HTML content.
    # ==== Return
    # HTML content.
    def to_html
      page = markdown.to_html
      path = File.dirname(file_path)
      # Get child content.
      # A reflexive.
      dirs(path).each do |dir|
        # Plus one indent from parent. Change h[1-6] tag to h[2-7] if indent is 1.
        doc = Document.new :base_path => dir, :lang => self.lang, :indent => self.indent + 1
        page += doc.to_html
      end
      page
    end
    
    private
    # Return file path
    # ==== Return
    # Document file path
    def file_path
      # TODO support extention.
      # TODO support file name change.
      "#{self.base_path}/README.#{self.lang}.md"
    end
    
    # Return file content or blank string
    # ==== Return
    # File content. Or blank string if file not found.
    def content
      File.exist?(self.file_path) ? open(self.file_path).read : ""
    end
    
    # Return Markdown object from content.
    # ==== Return
    # Markdown object
    def markdown
      RDiscount.new(exec_trans(content))
    end
    
    # Convert to something from content.
    # Currently, Change indent level.
    # TODO support plugin and expand format.
    # ==== Args
    # content :: File content
    # ==== Return
    # Text content.
    def exec_trans(content)
      self.indent.times do |i|
        content = content.to_s.gsub(/^#/, "## ")
      end
      content
    end
    
    # Judgment directry or not.
    # ==== Args
    # f :: File name, "." or ".."
    # path :: Directory path.
    # ==== Return
    # directory path or nil.
    def d(f, path)
      return nil if f =~ /^\./
      expand_path = File.expand_path(f, path)
      File::ftype(expand_path) == "directory" ? expand_path : nil
    end
    
    # Return child directories from target directory
    # ==== Args
    # path :: Target directory
    # ==== Return
    # Array. Only child directories.
    def dirs(path)
      ary = Dir.entries(path).collect do |f|
        d(f, path)
      end
      ary.delete(nil)
      ary
    end
  end
end
