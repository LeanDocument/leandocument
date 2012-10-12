# -*- coding: utf-8 -*-
# LeanDocument::Document class is converter to text from file content for LeanDocument
#
# Usage:
# @doc = Document.new(:lang => "ja")
# puts @doc.to_html
module Leandocument
  class Document
    SETTING_FILE_NAME = "settings.yml"
    SUPPORT_EXTENSIONS = %w(md textile markdown mdown rdoc org creole mediawiki)
    
    # lang :: Document language. TODO support default language.
    # settings :: LeanDocument Settings. TODO read settings.
    # base_path :: Document path.
    # indent :: Document indent. Child documents are plus on from parent. Then change to h[2-7] tag from h[1-6] tag. <h1> -> <h2>
    attr_accessor :lang, :settings, :base_path, :indent, :extension, :web_path, :title, :childs, :repository, :commit
    
    # Generate Document class.
    # ==== Args
    # options :: lang:Default document language. base_path: Document path. indent: Document indent level.
    # ==== Return
    # New Leandocument Document class.
    def initialize(options = {})
      self.lang = options[:lang] || settings["default_locale"]
      self.base_path = options[:base_path] || Dir.pwd
      self.web_path  = "#{options[:web_path]}/"
      self.indent = options[:indent] || 0
      self.settings = options[:settings] || load_config
      self.extension = get_extension
      self.childs = []
      self.repository = options[:repository]
      self.commit     = options[:commit]
      self.get_title
    end
    
    # Generate HTML content.
    # ==== Return
    # HTML content.
    def to_html
      page = render
      path = File.dirname(file_path)
      # Get child content.
      # A reflexive.
      dirs(path).each do |dir|
        # Plus one indent from parent. Change h[1-6] tag to h[2-7] if indent is 1.
        doc = Document.new :base_path => dir, :lang => self.lang, :indent => self.indent + 1, :settings => self.settings, :web_path => dir.gsub(self.base_path, ""), :commit => self.commit, :repository => self.repository
        self.childs << doc
        page += doc.to_html
      end
      page
    end
    
    protected
    
    def get_extension
      SUPPORT_EXTENSIONS.each do |ext|
        return ext if File.exist?(file_path(ext))
      end
      return nil
    end
    
    def content_ary
      content.split(/\r\n|\r|\n/)
    end
    
    def get_title
      self.title = content_ary[0]
    end
    
    def load_config
      path = "#{self.base_path}/#{SETTING_FILE_NAME}"
      File.exist?(path) ? YAML.load_file(path) : {}
    end
    
    def file_name(ext = nil)
      "README.#{self.lang}.#{ext ? ext : self.extension}"
    end
    
    # Return file path
    # ==== Return
    # Document file path
    def file_path(ext = nil)
      "#{self.base_path}/#{file_name(ext)}"
    end
    
    def find_content(tree = nil, path = nil)
      path = path || self.web_path.gsub(/^\//, "")
      paths = path.split("/")
      (tree || self.commit.tree).contents.each do |content|
        puts "content -> #{content.name}"
        if paths.size > 0
          return find_content(content, paths[1..-1].join("/")) if content.name == paths[0]
        else
          return content if content.name == file_name
        end
      end
    end
    
    # Return file content or blank string
    # ==== Return
    # File content. Or blank string if file not found.
    def content
      if self.commit
        return find_content ? find_content.data.force_encoding('UTF-8') : ""
      end
      File.exist?(self.file_path) ? open(self.file_path).read.force_encoding('UTF-8') : ""
    end
    
    def render
      send("render_#{self.extension}")
    end
    
    # Return Markdown object from content.
    # ==== Return
    # Markdown object
    def render_markdown
      RDiscount.new(exec_trans(content)).to_html
    end
    alias :render_md :render_markdown
    
    def setting_value(*ary)
      return nil unless self.settings
      results = self.settings
      ary.each do |key|
        return nil unless results[key]
        results = results[key]
      end
      results
    end
    
    # Convert to something from content.
    # Currently, Change indent level.
    # TODO support plugin and expand format.
    # ==== Args
    # content :: File content
    # ==== Return
    # Text content.
    def exec_trans(content)
      content = content_ary[1..-1].join("\n")
      self.indent.times do |i|
        content = content.to_s.gsub(/^#/, "##")
      end
      if self.commit
        content = content.gsub(/^!\[(.*)\]\((.*)\)/, '![\\1](/commits/'+self.commit.id + self.web_path+'\\2)') # For image
      else
        content = content.gsub(/^!\[(.*)\]\((.*)\)/, '![\\1]('+self.web_path+'\\2)') # For image
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
