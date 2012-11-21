# -*- coding: utf-8 -*-
# LeanDocument::Document class is converter to text from file content for LeanDocument
#
# Usage:
# @doc = Document.new(:lang => "ja")
# puts @doc.to_html
module Leandocument
  class Document
    SETTING_FILE_NAME = "settings.yml"
    SUPPORT_EXTENSIONS = %w(md textile markdown mdown rdoc org creole mediawiki rst rest)
    
    # lang :: Document language. TODO support default language.
    # settings :: LeanDocument Settings. TODO read settings.
    # base_path :: Document path.
    # indent :: Document indent. Child documents are plus on from parent. Then change to h[2-7] tag from h[1-6] tag. <h1> -> <h2>
    attr_accessor :lang, :settings, :base_path, :indent, :extension, :web_path, :childs, :repository, :commit, :browsers, :filename, :error_message
    
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
    
    def e?
      return (self.error_message = "File not found. #{file_path}(#{SUPPORT_EXTENSIONS.join("|")})") unless get_extension
      return (self.error_message = "Something wrong setting file. #{config_file_path}") unless self.settings
      return (self.error_message = "File convert error. Please check file encoding. LeanDocument is allow only UTF-8. #{file_path}") unless self.title
      nil
    end
    
    def e
      self.error_message
    end
    
    # Generate HTML content.
    # ==== Return
    # HTML content.
    def to_html
      return "" unless file_name
      return e if e?
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
        doc = Document.new :base_path => dir, :lang => self.lang, :indent => self.indent + 1, :settings => self.settings, :web_path => self.web_path[0..-2] + dir.gsub(self.base_path, ""), :commit => self.commit, :repository => self.repository
        self.childs << doc
        page += doc.to_html
      end
      page
    end
    
    def title
      return "" unless render
      begin
        render.title
      rescue ArgumentError => e
        nil
      end
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
    
    protected
    
    def get_extension
      SUPPORT_EXTENSIONS.each do |ext|
        next unless file_path(ext)
        return ext if File.exist?(file_path(ext))
      end
      return nil
    end
    
    def config_file_path
      "#{self.base_path}/#{SETTING_FILE_NAME}"
    end
    
    def load_config
      if File.exist?(config_file_path)
        begin
          YAML.load_file(config_file_path)
        rescue Psych::SyntaxError => e
          nil
        end
      else
        {}
      end
    end
    
    def file_name(ext = nil)
      return self.filename if self.filename
      basic_file_name(ext)
    end
    
    def basic_file_name(ext = nil)
      f = "README.#{self.lang}.#{ext ? ext : self.extension}"
      return f if File.exist? f
      ary = Dir.entries(self.base_path).collect do |f|
        if f =~ /^README\.([a-z]{2})\.(#{SUPPORT_EXTENSIONS.join("|")})/
            self.lang = $1
          self.extension = $2
          return f
        end
      end
      nil
    end
    
    # Return file path
    # ==== Return
    # Document file path
    def file_path(ext = nil)
      return nil unless file_name(ext)
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
    
    def render
      return nil unless self.extension
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
    
    def render_rst
      return @render if @render
      @render = ReStructuredText.new(:content => content, :indent => self.indent, :path => self.commit ? "/commits/#{self.commit.id}#{self.web_path}" : self.web_path)
      @render
    end
    alias :render_re_structured_text :render_rst
    alias :render_rest :render_rst
    
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
