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
    attr_accessor :lang, :settings, :base_path, :indent, :extension, :web_path, :childs, :repository, :commit, :browsers, :filename
    
    # Generate Document class.
    # ==== Args
    # options :: lang:Default document language. base_path: Document path. indent: Document indent level.
    # ==== Return
    # New Leandocument Document class.
    def initialize(options = {})
      self.base_path = options[:base_path] || Dir.pwd
      self.settings = options[:settings] || load_config
      self.lang = options[:lang] || setting_value("settings", "default_locale")
      self.web_path  = "#{options[:web_path]}/"
      self.indent = options[:indent] || 1
      self.extension = get_extension
      self.filename = options[:filename] || file_name
      self.childs = []
      self.browsers = []
      self.repository = options[:repository]
      self.commit     = options[:commit]
    end
    
    # Generate HTML content.
    # ==== Return
    # HTML content.
    def to_html
      return "" unless self.extension
      page = render.to_html
      path = File.dirname(file_path)
      # Get child content.
      # A reflexive.
      files(path).each do |file|
        doc = Document.new :base_path => self.base_path, :lang => self.lang, :indent => self.indent, :settings => self.settings, :web_path => self.web_path, :commit => self.commit, :repository => self.repository, :filename => file
        self.browsers << doc
        page += doc.to_html
      end
      dirs(path).each do |dir|
        # Plus one indent from parent. Change h[1-6] tag to h[2-7] if indent is 1.
        doc = Document.new :base_path => dir, :lang => self.lang, :indent => self.indent + 1, :settings => self.settings, :web_path => dir.gsub(self.base_path, ""), :commit => self.commit, :repository => self.repository
        self.childs << doc
        page += doc.to_html
      end
      page
    end
    
    def title
      render.title
    end
    
    def toc
      return @toc if @toc
      @toc = render.toc
      self.childs.each do |doc|
        @toc += doc.toc
      end
      @toc
    end
    
    def toc=(toc)
      @toc += toc
    end
    
    protected
    
    def get_extension
      SUPPORT_EXTENSIONS.each do |ext|
        return ext if File.exist?(file_path(ext))
      end
      return nil
    end
    
    def load_config
      path = "#{self.base_path}/#{SETTING_FILE_NAME}"
      File.exist?(path) ? YAML.load_file(path) : {}
    end
    
    def file_name(ext = nil)
      return self.filename if self.filename
      basic_file_name(ext)
    end
    
    def basic_file_name(ext = nil)
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
      return @content if @content
      if self.commit
        @content = find_content ? find_content.data.force_encoding('UTF-8') : ""
      else
        @content = File.exist?(self.file_path) ? open(self.file_path).read.force_encoding('UTF-8') : ""
      end
      @content
    end
    
    def render
      send("render_#{self.extension}")
    end
    
    # Return Markdown object from content.
    # ==== Return
    # Markdown object
    def render_markdown
      return @render if @render
      @render = Markdown.new(:content => content, :indent => self.indent, :path => self.commit ? "/commits/#{self.commit.id}#{self.web_path}" : self.web_path)
      @render
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
    
    def f(f, path)
      return nil if f =~ /^\./
      expand_path = File.expand_path(f, path)
      File::ftype(expand_path) == "file" && browser?(f) ? f : nil
    end
    
    def browser?(f)
      return nil if f == basic_file_name
      f =~ /^README.*\.#{self.lang}\.#{self.extension}/
    end
    
    def files(path)
      return [] if self.filename != basic_file_name
      ary = Dir.entries(path).collect do |f|
        f(f, path)
      end
      ary.delete(nil)
      ary
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
